defmodule BullsAndCowsPart1Test do
  use ExUnit.Case

  test "Scores a guess with no match" do
    assert BullsAndCows.score_guess("1234", "5678") == "0 Bulls, 0 Cows"
    assert BullsAndCows.score_guess("2345", "6789") == "0 Bulls, 0 Cows"
  end

  test "Scores a guess with one Bull" do
    assert BullsAndCows.score_guess("1234", "1678") == "1 Bulls, 0 Cows"
    assert BullsAndCows.score_guess("2345", "6785") == "1 Bulls, 0 Cows"
  end

  test "Scores a guess with one Cow" do
    assert BullsAndCows.score_guess("1234", "5671") == "0 Bulls, 1 Cows"
    assert BullsAndCows.score_guess("2345", "5678") == "0 Bulls, 1 Cows"
  end

  test "Scores a guess with one Bull and one Cow" do
    assert BullsAndCows.score_guess("1234", "5271") == "1 Bulls, 1 Cows"
    assert BullsAndCows.score_guess("2345", "5648") == "1 Bulls, 1 Cows"
  end

  test "Scores a guess with two Bulls" do
    assert BullsAndCows.score_guess("1234", "5236") == "2 Bulls, 0 Cows"
    assert BullsAndCows.score_guess("2345", "2685") == "2 Bulls, 0 Cows"
  end

  test "Scores a guess with two Cows" do
    assert BullsAndCows.score_guess("1234", "5623") == "0 Bulls, 2 Cows"
    assert BullsAndCows.score_guess("2345", "1238") == "0 Bulls, 2 Cows"
  end

  test "Scores a guess with three Bulls" do
    assert BullsAndCows.score_guess("1234", "1236") == "3 Bulls, 0 Cows"
    assert BullsAndCows.score_guess("2345", "2385") == "3 Bulls, 0 Cows"
  end

  test "Scores a winning guess" do
    assert BullsAndCows.score_guess("1234", "1234") == "You win"
    assert BullsAndCows.score_guess("2345", "2345") == "You win"
  end  
end
