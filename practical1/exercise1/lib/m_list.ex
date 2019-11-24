defmodule MList do
    def map([], _fun), do: []
    def map([head|tail], fun), do: [fun.(head) | map(tail, fun)]

    def foldl([], acc, _fun), do: acc
    def foldl([head|tail], acc, fun), do: foldl(tail, fun.(head, acc), fun)

    def filter([], _fun), do: []
    def filter([head|tail], fun) do
      case fun.(head) do
          true -> [head | filter(tail, fun)]
          _ -> filter(tail, fun)
      end
    end
end