defmodule Bowling.API.V1.ThrowControllerTest do
  use BowlingWeb.ConnCase

  alias Bowling.Factory

  describe "POST create/2" do
    test "creates a new throw", %{conn: conn} do
      game = Factory.insert(:game)
      params = %{value: 5}

      request =
        post(conn, Routes.api_v1_game_frame_throw_path(conn, :create, game.uuid, 1), params)

      assert request.status == 201
      assert %{"number" => 0, "value" => 5} = Jason.decode!(request.resp_body)
    end

    test "can not find the game", %{conn: conn} do
      request =
        post(conn, Routes.api_v1_game_frame_throw_path(conn, :create, Ecto.UUID.generate(), 1), %{
          value: 8
        })

      assert request.status == 404

      assert %{"error" => "The game with specified uuid is not found"} =
               Jason.decode!(request.resp_body)
    end

    test "can not create the second frame without the first fram", %{conn: conn} do
      game = Factory.insert(:game)
      params = %{value: 5}

      request =
        post(conn, Routes.api_v1_game_frame_throw_path(conn, :create, game.uuid, 2), params)

      assert request.status == 422

      assert %{"error" => "Frame is not valid. It doesn't satisfy game logic"} =
               Jason.decode!(request.resp_body)
    end
  end
end
