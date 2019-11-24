defmodule Game do
    use GenServer
    import BullsAndCows
  
    @max_turns 9
    def max_turns, do: @max_turns
  
    @derive [Poison.Encoder] # This will be used in part 3 to generate JSON
    defstruct [
      turns_left: @max_turns, 
      current_state: :playing,  
      last_guess: "", 
      feedback: ""
    ]
  
    def start_link() do
      GenServer.start_link(__MODULE__, [Secret.new()])
    end

    def start_link(name \\ Game) do
        GenServer.start_link(__MODULE__, [Secret.new()], name: name)
    end
  
    def init([secret]) do
      game = %Game{}
      {:ok, {game,secret}}
    end

    #returns Game
    def game_state(pid) do
        GenServer.call(pid, {:getGame})
    end

    def get_secret(pid) do
        GenServer.call(pid, {:getSecret})
    end

    def handle_call({:getGame}, _from, state) do
        {:reply, elem(state,0), state}
    end

    def handle_call({:getSecret}, _from, state) do
        {:reply, elem(state,1), state}
    end

    def submit_guess(pid, guess) do
        GenServer.cast(pid, {:submit,guess})
    end

    def handle_cast({:submit,guess}, state) do
        previousGame = elem(state,0)
        secret = elem(state,1)
        game = updateGame(previousGame,secret,guess)
        {:noreply, {game,secret}}
     end

    def updateGame(previousGame,secret,guess) do
        if score_guess(secret, guess) != "You win" do
            turnLeft = previousGame.turns_left - 1
            if turnLeft <= 0 do
                %Game{turns_left: 0, 
                current_state: :lost,  
                last_guess: guess, 
                feedback: score_guess(guess, secret)}
            else
                %Game{turns_left: turnLeft, 
                current_state: :playing, 
                last_guess: guess, 
                feedback: score_guess(guess, secret)}
            end    
        else  
            %Game{turns_left: (previousGame.turns_left - 1), 
            current_state: :playing,
            last_guess: guess, 
            feedback: score_guess(guess, secret)} 
        end
    end

  end