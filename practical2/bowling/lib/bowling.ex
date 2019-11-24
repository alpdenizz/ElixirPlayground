defmodule Bowling do
  def score(game) do
    score(game, 0)
  end
  def score([[a,b,_]],acc) do 
    a + b + acc
  end
  def score([[10,_]| tail],acc) do
    [a, b] = hd tail
    score(tail, acc+10+a+b)
  end
  def score([[a,b]|tail], acc) when a+b==10 do
    [next_turn | _] = hd tail
    score(tail, acc + a + b) + next_turn
  end
  def score([[a,b]|tail], acc) do
    score(tail, acc + a + b)
  end
end