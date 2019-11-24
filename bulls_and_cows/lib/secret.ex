defmodule Secret do
    def new, do: Enum.take_random(0..9, 4) |> Enum.join
end