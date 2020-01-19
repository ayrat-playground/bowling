defmodule Bowling.API.V1.GameControllerTest do
  use BowlingWeb.ConnCase

  describe "POST create/2" do
    test "creates a new game", %{conn: conn} do
      request = post(conn, Routes.api_v1_game_path(conn, :create))

      assert request.status == 201
      assert %{"uuid" => _, "frames" => []} = Jason.decode!(request.resp_body)
    end
  end
end
