defmodule WhiteBreadContext do
  use WhiteBread.Context
  use Hound.Helpers
  alias Takso.{Repo,Trip}

  feature_starting_state fn  ->
    Application.ensure_all_started(:hound)
    %{}
  end
  scenario_starting_state fn _state ->
    Ecto.Adapters.SQL.Sandbox.checkout(Takso.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Takso.Repo, {:shared, self()})
    Hound.start_session
    %{}
  end
  scenario_finalize fn _status, _state -> 
    Ecto.Adapters.SQL.Sandbox.checkin(Takso.Repo)
    # Hound.end_session
  end

  given_ ~r/^STRS's ride history includes the following trips$/, 
  fn state, %{table_data: table} ->
    table
    |> Enum.map(fn trip -> Trip.changeset(%Trip{}, trip) end)
    |> Enum.each(fn changeset -> Repo.insert!(changeset) end)
    {:ok, state}
  end
  and_ ~r/^"(?<argument_one>[^"]+)" lodges a customer service request/,
  fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end
  and_ ~r/^the lost object is a "(?<argument_one>[^"]+)"$/,
  fn state, %{argument_one: _argument_one} ->
    {:ok, state}
  end
  and_ ~r/^the date of the (loss|trip) is "(?<date>[^"]+)"$/,
  fn state, %{date: date} ->
    {:ok, Map.put(state, :date,  date)}
  end
  when_ ~r/^the operator enters the date of loss$/, fn state ->
    navigate_to "/lost_and_found"
    input_into_field({:id, "date_of_trip"}, state[:date])
    click({:id, "submit_button"})
    {:ok, state}
  end
  then_ ~r/^the operator should see (?<rows>\d+) rows$/, fn state, %{rows: rows} ->
    {rows, _} = Integer.parse(rows)
    assert length(find_all_elements(:css, ".table_row")) == rows
    {:ok, state}
  end
  when_ ~r/^the operator enters "(?<pickup_address>[^"]+)" as pickup address$/,
  fn state, %{pickup_address: pickup_address} ->
    fill_field({:id, "pickup_address"}, pickup_address)
    click({:id, "submit_button"})    
    {:ok, state}
  end

  # ==== Additional for part 2

  and_ ~r/^the taxi ride was from "(?<pickup_address>[^"]+)" to "(?<dropoff_address>[^"]+)"$/,
  fn state, %{pickup_address: pickup_address, dropoff_address: dropoff_address} ->
    {:ok, state |> Map.put(:pickup_address, pickup_address) |> Map.put(:dropoff_address, dropoff_address)}
  end
  when_ ~r/^the operator enters the date, pickup and drop off addresses of the trip$/, fn state ->
    navigate_to "/scam_analysis"
    input_into_field({:id, "date_of_incident"}, state[:date_of_incident])
    fill_field({:id, "pickup_address"}, state[:pickup_address])
    fill_field({:id, "dropoff_address"}, state[:dropoff_address])
    click({:id, "submit_button"})
    {:ok, state}
  end
  then_ ~r/^the operator should see (?<number_of_rows>\d+) rows? associated with taxi (?<taxi_id>\d+)$/, 
  fn state, %{number_of_rows: number_of_rows, taxi_id: taxi_id} ->
    rows = find_all_elements(:css, ".table_row")
    {number_of_rows, _} = Integer.parse(number_of_rows)
    assert length(rows) == number_of_rows
    assert Enum.all? rows, fn row -> visible_text(find_within_element(row, :css, ".taxi_id")) == taxi_id end
    {:ok, state}
  end
  when_ ~r/^the operator clears the form$/, fn state ->
    click({:id, "clear_button"})    
    {:ok, state}
  end

  and_ ~r/^the operator enters the taxi identifier (?<taxi_id>\d+)$/, 
  fn state, %{taxi_id: taxi_id} ->
    fill_field({:id, "taxi_id"}, taxi_id)
    click({:id, "submit_button"})    
    {:ok, state}
  end

  then_ ~r/^the operator should see (?<rows>\d+)(?<overprice>( yellow| red)?) rows?$/,
  fn state, %{rows: number_of_rows, overprice: overprice} ->
    rows = find_all_elements(:css, ".table_row")
           |> filter_overpriced(overprice)
    {number_of_rows, _} = Integer.parse(number_of_rows)           
    assert length(rows) == number_of_rows
    {:ok, state}
  end

  def filter_overpriced(rows, " yellow") do
    Enum.filter(rows, fn row -> has_class?(row, "warning") end)
  end
  def filter_overpriced(rows, " red") do
    Enum.filter(rows, fn row -> has_class?(row, "danger") end)
  end
  def filter_overpriced(rows, _), do: rows
  
  when_ ~r/^the operator filters (?<percentage>\d+)%.*overpriced trips$/,
  fn state, %{percentage: percentage} ->
    case percentage do
      "25" -> click({:id, "checkbox_25plus"})
      "50" -> click({:id, "checkbox_50plus"})
    end
    click({:id, "submit_button"})
    {:ok, state}
  end
end
