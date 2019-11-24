defmodule WhiteBreadContext do
  use WhiteBread.Context
  use Hound.Helpers
  alias Takso.{Repo,Taxi,User}
  @decision_timeout Application.get_env(:takso, :decision_timeout)
  
  feature_starting_state fn  ->
    Application.ensure_all_started(:hound)
    parent = self()    
    %{}
  end
  scenario_starting_state fn state ->
    Hound.start_session
    Ecto.Adapters.SQL.Sandbox.checkout(Takso.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Takso.Repo, {:shared, self()})
    %{}
  end
  scenario_finalize fn _status, _state ->
    Ecto.Adapters.SQL.Sandbox.checkin(Takso.Repo)
    Hound.end_session
  end 

  given_ ~r/^the following taxis are on duty$/, 
  fn state, %{table_data: table} ->
    table
    |> Enum.map(fn taxi -> Taxi.changeset(%Taxi{}, taxi) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)

    {:ok, state}
  end

  and_ ~r/^the status of the taxis is "(?<statuses>[^"]+)"$/,
  fn state, %{statuses: statuses} ->
    IO.inspect("################ PREPARE THE SCENARIO ######################################")
    String.split(statuses, ",")
    |> Enum.with_index
    |> Enum.map(fn {status, index} -> 
          Repo.get_by!(Taxi, username: "taxi#{index + 1}")
          |> Taxi.changeset(%{status: status})
          |> Repo.update!
        end)
    {:ok, state}
  end

  and_ ~r/^I want to go from "(?<pickup_address>[^"]+)" to "(?<dropoff_address>[^"]+)"$/,
  fn state, %{pickup_address: pickup_address, dropoff_address: dropoff_address} ->
    {:ok, state |> Map.put(:pickup_address, pickup_address) |> Map.put(:dropoff_address, dropoff_address)}
  end

  and_ ~r/^I enter the booking information on the STRS Customer app$/, 
  fn state ->
    # 1. Insert a new user in the database (you can choose a username here)
    Repo.insert(User.changeset(%User{}, %{name: "Fred Flintstone", username: "fred", password: "parool", role: "customer"}))
    
    # (Session :default will be used by customer)
    in_browser_session String.to_atom("fred"), fn ->
      # 2. Log in the application with the user credentials
      navigate_to "/#/login"
      fill_field({:id, "username"}, "fred")
      fill_field({:id, "password"}, "parool")
      click({:id, "loginButton"})
      # 3. Enter the information about the booking
      fill_field({:id, "pickup_address"}, state[:pickup_address])
      fill_field({:id, "dropoff_address"}, state[:dropoff_address])
    end
    {:ok, state}
  end

  and_ ~r/^"(?<taxi_username1>[^"]+)" "(?<taxi_username2>[^"]+)" are online$/,
  fn state, %{taxi_username1: taxi_username1, taxi_username2: taxi_username2} ->
    #IO.inspect(taxi_username)
    # 1. Insert a new user in the database for this taxi driver
    Repo.insert(User.changeset(%User{}, %{name: "Frodo Baggins", username: taxi_username1, password: "parool", role: "taxi-driver"}))
    Repo.insert(User.changeset(%User{}, %{name: "Bilbo Baggins", username: taxi_username2, password: "parool", role: "taxi-driver"}))
    # 2. Log in the application with the taxi driver credentials
    # -- Note that we are switching to a browser session for this taxi driver!
    in_browser_session String.to_atom(taxi_username1), fn ->
      navigate_to "/#/login"
      fill_field({:id, "username"}, taxi_username1)
      fill_field({:id, "password"}, "parool")
      click({:id, "loginButton"})
    end
    in_browser_session String.to_atom(taxi_username2), fn ->
      navigate_to "/#/login"
      fill_field({:id, "username"}, taxi_username2)
      fill_field({:id, "password"}, "parool")
      click({:id, "loginButton"})
    end
    {:ok, state}
  end

  when_ ~r/^I summit the booking request$/, fn state ->
    in_browser_session String.to_atom("fred"), fn ->
      # Submit the request as usual
      click({:id, "requestButton"})
    end
    {:ok, state}
  end

  and_ ~r/^"(?<taxi_username>[^"]+)" decides to "(?<decision>[^"]+)"$/,
  fn state, %{taxi_username: taxi_username, decision: decision} ->
    IO.inspect("################### TAXI DRIVER: "<>taxi_username<>" ###################################")
    in_browser_session String.to_atom(taxi_username), fn ->
      case decision do
        "reject" -> 
          IO.puts "Taxi driver clicks reject button"
          click({:id, "rejectButton"})
          
        "accept" -> 
          IO.puts "Taxi driver clicks accept button"
          click({:id, "acceptButton"})
          
        _ -> 
          Process.sleep(@decision_timeout)
          IO.puts "Taxi driver does ... nothing (the system will timeout eventually)"
          
        end
    end
    {:ok, state}
   end

  then_ ~r/^I should be notified "(?<notification>[^"]+)"$/,
  fn state, %{notification: notification} ->
    in_browser_session String.to_atom("fred"), fn ->
      r = Regex.compile!(notification)
      message = attribute_value({:class, "col-sm-12"}, "value")
      assert String.match?(message, r)
    end
   {:ok, state}
  end

end