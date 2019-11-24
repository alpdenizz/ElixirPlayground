defmodule Takso.BookingAPIController do
  use Takso.Web, :controller
  import Ecto.Query, only: [from: 2]
  alias Takso.{Taxi,Repo,Booking}
  
  def create(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    changeset = Booking.changeset(%Booking{}, params)
    booking = Repo.insert!(changeset)
    IO.inspect("#####################BOOKING ID: #{booking.id} ###################################")

    query = from t in Taxi, where: t.status == "available", select: t
    available_taxis = Repo.all(query)
    if length(available_taxis) > 0 do
      taxi = List.first(available_taxis)
      remainingTaxis = tl available_taxis
      # The following line broadcasts the booking request through the private taxi driver's channel
      # (I assume that the same user may have multiple devices connected to such channel)
      Takso.Endpoint.broadcast("driver:"<>taxi.username, "requests", params |> Map.put(:booking_id, booking.id) |> Map.put("visibility",true))
      Takso.TaxiAllocator.start_link(params |> Map.put(:customer_username, user.username) |> Map.put(:remainingTaxis, remainingTaxis) |> Map.put(:booking_id, booking.id) |> Map.put(:currentTaxi, taxi.username), String.to_atom("booking_#{booking.id}"))


      conn
      |> put_status(201)
      |> json(%{msg: "We are processing your request"})
    else
      conn
      |> put_status(406)
      |> json(%{msg: "Our apologies, we cannot serve your request in this moment"})
    end
  end

  def update(conn, params) do
    %{"id" => booking_id} = params
    %{"status" => status} = params 
    # The following line will broadcast a message through the channel "customer:lobby" announcing that the taxi will arrive in 5 mins
    # Henceforth, the following line must be updated for using private channels

    # Note that, additionally, the line above should be relocated to the GenServer
    # Consider using the following line (note that accept_booking is already defined in TaxiAllocator)
    case status do
      "accepted" -> Takso.TaxiAllocator.accept_booking(String.to_atom("booking_#{booking_id}"))
      "rejected" -> Takso.TaxiAllocator.reject_booking(String.to_atom("booking_#{booking_id}"))
    end

    conn
    |> put_status(200)
    |> json(%{msg: "Notification sent to the customer"})
  end
end