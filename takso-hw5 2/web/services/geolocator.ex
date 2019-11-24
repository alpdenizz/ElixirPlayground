defmodule Takso.Geolocator do
    @http_client Application.get_env(:takso, :http_client)
  
    def trip_duration(origin, destination) do
      origin = String.replace(origin," ","+")
      destination = String.replace(destination," ","+")
      %{body: body} = @http_client.get!("http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{origin}+Tartu+Estonia&destinations=#{destination}+Tartu+Estonia")      
      %{"rows" => list} = Poison.decode!(body)
      list = Enum.filter(list, fn(%{"elements" => [%{"status"=> x}]}) -> x == "OK"  end)
      if list == [] do
        "NOT AVAILABLE LOCATION"
      else
      ways = Enum.map(list, fn(%{"elements" => [%{"duration"=> x}]}) -> x end)
      min = Enum.map(ways, fn(%{"value"=>value})->value end)
      min = Enum.min(min)
      %{"text"=>str} = Enum.filter(ways, fn(%{"value"=>value}) -> value==min end) |> List.first()
      str
      end
    end
  end