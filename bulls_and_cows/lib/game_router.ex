defmodule GameRouter do
  use Plug.Router

  plug :match
  plug Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Poison
  plug :dispatch

  def start_link do
    Plug.Adapters.Cowboy.http(GameRouter, [])
  end

  post "/games" do
    id = UUID.uuid1()
    {:ok, _} = Game.start_link(String.to_atom(id))
    conn
    |> put_resp_header("Location", "/games/#{id}")
    |> send_resp(201, "Your game has been created")
  end

  get "/games/:id" do
    id = String.to_atom(id)
    if Process.whereis(id) != nil do
      state = Game.game_state(id)
      send_resp(conn, 200, Poison.encode!(state))
    else
      send_resp(conn, 404, "Game URL is unknown")
    end
  end

  post "/games/:id/guesses" do
    id = String.to_atom(id)
    %{"guess" => guess} = conn.body_params
    if Process.whereis(id) != nil do
      Game.submit_guess(id, guess)
      state = Game.game_state(id)
      send_resp(conn, 201, Poison.encode!(state))
    else
      send_resp(conn, 404, "Game URL is unknown")
    end
  end

  match _ do
    send_resp(conn, 404, "Oops")
  end
end