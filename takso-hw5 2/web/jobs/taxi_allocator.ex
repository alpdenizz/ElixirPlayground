defmodule Takso.TaxiAllocator do
    use GenServer
    @decision_timeout Application.get_env(:takso, :decision_timeout)
    
    def start_link(request, booking_reference) do
        GenServer.start_link(Takso.TaxiAllocator, request, name: booking_reference)
    end
        
    def init(request) do
        IO.inspect("##################### GENSERVER FOR TAXI DRIVER ################################################")
        timerRef = Process.send_after(self(), :notify_customer, @decision_timeout)
        {:ok, request |> Map.put("timerRef",timerRef)}
    end

    def accept_booking(booking_reference) do
        GenServer.cast(booking_reference, :accept_booking)
    end

    def reject_booking(booking_reference) do
        GenServer.cast(booking_reference, :reject_booking)
    end

    def handle_cast(:accept_booking, request) do
        IO.inspect("##################### I AM ON MY WAY ################################################")
        %{"timerRef" => timerRef} = request
        Process.cancel_timer(timerRef)
        %{customer_username: customerName} = request
        Takso.Endpoint.broadcast("customer:"<>customerName, "requests", %{msg: "taxi arriving soon"})
        {:noreply, request}
    end

    def handle_cast(:reject_booking, request) do
        %{"timerRef" => timerRef} = request
        Process.cancel_timer(timerRef)
        %{customer_username: customerName} = request
        %{remainingTaxis: remainingTaxis} = request
        %{booking_id: bookingId} = request
        %{"pickup_address" => pickup} = request
        %{"dropoff_address" => dropoff} = request
        case remainingTaxis do
            [] -> 
                IO.inspect("############# THERE IS NO DRIVER SIR/MADAM SORRY - REJECT EMPTY LIST ##############################")
                Takso.Endpoint.broadcast("customer:"<>customerName, "requests", %{msg: "no taxi available"})
                {:noreply, request}
            _ -> 
                IO.inspect("##################### CANNOT SERVE RIGHT NOW ################################################")
                taxi = List.first(remainingTaxis)
                info = %{"visibility"=>true} |> Map.put("pickup_address", pickup) |> Map.put("dropoff_address", dropoff) |> Map.put(:booking_id, bookingId+50)
                Takso.Endpoint.broadcast("driver:"<>taxi.username, "requests", info)
                leftTaxis = tl remainingTaxis
                params = %{} |> Map.put(:customer_username, customerName) |> Map.put(:remainingTaxis, leftTaxis) 
                             |> Map.put("pickup_address", pickup) |> Map.put("dropoff_address", dropoff)
                             |> Map.put(:booking_id, bookingId+50) |> Map.put(:currentTaxi, taxi.username)
                start_link(params, String.to_atom("booking_#{bookingId+50}"))
                {:noreply, params}
                
        end
    end

    def handle_info(:notify_customer, request) do
        # With the following line, the backend is broadcasting a message through the channel "customer:lobby"
        # Henceforth, the following line must be updated for using private channels
        %{currentTaxi: curr} = request
        Takso.Endpoint.broadcast("driver:"<>curr, "requests", %{"visibility"=>false})
        %{customer_username: customerName} = request
        %{remainingTaxis: remainingTaxis} = request
        %{booking_id: bookingId} = request
        %{"pickup_address" => pickup} = request
        %{"dropoff_address" => dropoff} = request
        
        case remainingTaxis do
            [] -> 
                IO.inspect("############## THERE IS NO DRIVER SORRY SIR/MADAM - TIMEOUT EMPTY LIST ###########################")
                Takso.Endpoint.broadcast("customer:"<>customerName, "requests", %{msg: "no taxi available"})
                {:noreply, request}
            _ -> 
                IO.inspect("################# NEXT DRIVER PLEASE - PREVIOUS DRIVER FAILED RESPONSING ##############################")
                taxi = List.first(remainingTaxis)
                info = %{"visibility"=>true} |> Map.put("pickup_address", pickup) |> Map.put("dropoff_address", dropoff) |> Map.put(:booking_id, bookingId+50)
                Takso.Endpoint.broadcast("driver:"<>taxi.username, "requests", info)
                leftTaxis = tl remainingTaxis
                params = %{} |> Map.put(:customer_username, customerName) |> Map.put(:remainingTaxis, leftTaxis) 
                             |> Map.put("pickup_address", pickup) |> Map.put("dropoff_address", dropoff)
                             |> Map.put(:booking_id, bookingId+1) |> Map.put(:currentTaxi, taxi.username)
                start_link(params, String.to_atom("booking_#{bookingId+50}"))
                {:noreply, params}        
                end
    end
end