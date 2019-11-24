defmodule Stack2 do
    use GenServer
    
    def start_link do
        GenServer.start_link(Stack2, [])
    end

    #Process high level API
    def push(pid, value) do
       GenServer.cast(pid, {:push,value})
    end
    def pop(pid) do
       GenServer.call(pid, {:pop})
    end
    #Callbacks
    def handle_call({:pop}, _from, state) do
       {:reply, hd(state), tl(state)}
    end
    def handle_cast({:push,value}, state) do
       {:noreply, [value|state]}
    end
end