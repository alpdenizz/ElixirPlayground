defmodule BullsAndCowsPart3Test do
    use ExUnit.Case
    use Plug.Test
  
    @opts GameRouter.init([])
  
    test "Reports path / is not served by the application" do
      conn = conn(:get, "/")
      conn = GameRouter.call(conn, @opts)
      assert conn.status == 404
      assert conn.resp_body == "Oops"
    end

    test "Creates a new game" do
        conn = conn(:post, "/games")
        conn = GameRouter.call(conn, @opts)
        assert conn.status == 201
        assert conn.resp_body == "Your game has been created"
      end

    test "Retrieves game state" do
        conn = conn(:post, "/games")
        conn = GameRouter.call(conn, @opts)
        list = conn.resp_headers
        locTuple = Enum.filter(list, fn{x,y} -> x=="Location" end) 
        loc = elem((hd locTuple),1)
        conn2 = conn(:get, loc)
        conn2 = GameRouter.call(conn2,@opts)
        assert conn2.status == 200
      end

      test "Could not retrieve game state" do
        conn = conn(:post, "/games")
        conn = GameRouter.call(conn, @opts)
        list = conn.resp_headers
        locTuple = Enum.filter(list, fn{x,y} -> x=="Location" end) 
        loc = elem((hd locTuple),1)
        conn2 = conn(:get, loc<>"123")
        conn2 = GameRouter.call(conn2,@opts)
        assert conn2.status == 404
        assert conn2.resp_body == "Game URL is unknown"
      end

      test "Submits player’s guess" do
        conn = conn(:post, "/games")
        conn = GameRouter.call(conn, @opts)
        list = conn.resp_headers
        locTuple = Enum.filter(list, fn{x,y} -> x=="Location" end) 
        loc = elem((hd locTuple),1)
        loc2 = elem((hd locTuple),1)<>"/guesses"
        conn2 = conn(:post, loc2, "{\"guess\": \"1234\"}") |> put_req_header("content-type", "application/json")
        conn2 = GameRouter.call(conn2,@opts)
        conn3 = conn(:get, loc)
        conn3 = GameRouter.call(conn3,@opts)
        decoded = Poison.decode!(conn3.resp_body)
        %{"last_guess" => last_guess} = decoded
            assert conn2.status == 201
            assert conn3.status == 200
            assert last_guess = "1234"
      end

      test "Could not submit player's guess" do
        conn = conn(:post, "/games")
        conn = GameRouter.call(conn, @opts)
        list = conn.resp_headers
        locTuple = Enum.filter(list, fn{x,y} -> x=="Location" end) 
        loc = elem((hd locTuple),1)
        loc2 = elem((hd locTuple),1)<>"123"<>"/guesses"
        conn2 = conn(:post, loc2, "{\"guess\": \"1234\"}") |> put_req_header("content-type", "application/json")
        conn2 = GameRouter.call(conn2,@opts)
          assert conn2.status == 404
          assert conn2.resp_body == "Game URL is unknown"
      end
  end