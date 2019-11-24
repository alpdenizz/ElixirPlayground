defmodule Takso.CustomerServiceView do
  use Takso.Web, :view
  use Timex
  alias Timex.Format.DateTime.Formatters.Strftime

  def select_highlighting_color(%{pickup_time: pickup_time, dropoff_time: dropoff_time,
    est_duration: est_duration}, checkbox_25plus, checkbox_50plus) do

    est_duration_in_seconds = Duration.to_seconds(Duration.from_time(est_duration))
    act_duration_in_seconds = abs(Time.diff(pickup_time, dropoff_time))
    cond do
      checkbox_50plus == "true" and act_duration_in_seconds >= est_duration_in_seconds * 1.5 ->
        "50+"
      checkbox_25plus == "true" and act_duration_in_seconds >= est_duration_in_seconds * 1.25 ->
        "25+"
      true -> ""
    end
  end
end
