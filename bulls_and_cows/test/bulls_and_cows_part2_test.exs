defmodule BullsAndCowsPart2Test do
  use ExUnit.Case
  import Mock

  test "Creates a process holding the game state" do
    with_mock Secret, [new: fn() -> "1234" end] do
      {:ok, pid} = Game.start_link()
      assert is_pid(pid)
      assert pid != self()
      assert called Secret.new
    end
  end

  test "Removes 'secret' from the current game state" do
    {:ok, pid} = Game.start_link()
    state = Game.game_state(pid)
    refute Map.has_key?(state, :secret)
  end

  test "Keeps track of a dumb player's game" do
    with_mock Secret, [new: fn() -> "1234" end] do
      {:ok, pid} = Game.start_link()
      Enum.each 1..5, fn (turns_played) ->
        Game.submit_guess(pid, Enum.take_random(5..9, 4) |> Enum.join)
        state = Game.game_state(pid)
        assert state.current_state == :playing
        assert state.turns_left == Game.max_turns - turns_played
      end
    end
  end

  test "Stops and declares loss after 9 wrong guesses" do
    with_mock Secret, [new: fn() -> "1234" end] do
      {:ok, pid} = Game.start_link()
      Enum.each 1..Game.max_turns+1, fn (turns_played) ->
        # We use again the dumb player
        Game.submit_guess(pid, Enum.take_random(5..9, 4) |> Enum.join)
        if turns_played >= Game.max_turns do
          state = Game.game_state(pid)
          assert state.current_state == :lost
          assert state.turns_left == 0
        end
      end
    end
  end

  test "Keeps track and announces a winning game" do
    with_mock Secret, [new: fn() -> "1234" end] do
      {:ok, pid} = Game.start_link()
      turns = [
        {"1567", "1 Bulls, 0 Cows"},
        {"1527", "1 Bulls, 1 Cows"},            
        {"1237", "3 Bulls, 0 Cows"},            
        {"1234", "You win"}
      ]
      Enum.each turns, fn ({guess, feedback}) ->
        Game.submit_guess(pid, guess)
        game = Game.game_state(pid)
        assert game.feedback == feedback 
      end
    end
  end
end