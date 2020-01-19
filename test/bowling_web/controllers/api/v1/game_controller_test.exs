defmodule Bowling.API.V1.GameControllerTest do
  use BowlingWeb.ConnCase

  alias Bowling.Factory
  alias Bowling.Scoring.Game

  describe "POST create/2" do
    test "creates a new game", %{conn: conn} do
      request = post(conn, Routes.api_v1_game_path(conn, :create))

      assert request.status == 201
      assert %{"uuid" => _, "frames" => []} = Jason.decode!(request.resp_body)
    end
  end

  describe "GET score/2" do
    test "successfully calculates the score", %{conn: conn} do
      game = Factory.insert(:game)

      frame1 = Factory.insert(:frame, game: game, number: 1)
      Factory.insert(:throw, frame: frame1, value: 10, number: 0)

      frame2 = Factory.insert(:frame, game: game, number: 2)
      Factory.insert(:throw, frame: frame2, value: 5, number: 0)
      Factory.insert(:throw, frame: frame2, value: 4, number: 1)

      request = get(conn, Routes.api_v1_game_score_path(conn, :score, game))

      assert request.status == 200
      assert %{"1" => 19, "2" => 28} = Jason.decode!(request.resp_body)
    end

    test "fails when not existing uuid is provided", %{conn: conn} do
      request =
        get(conn, Routes.api_v1_game_score_path(conn, :score, %Game{uuid: Ecto.UUID.generate()}))

      assert request.status == 404

      assert %{"error" => "The game with specified uuid is not found"} =
               Jason.decode!(request.resp_body)
    end

    test "fails when not uuid is invalid", %{conn: conn} do
      request = get(conn, Routes.api_v1_game_score_path(conn, :score, %Game{uuid: "1"}))

      assert request.status == 400
      assert %{"error" => "Provided uuid is not valid"} = Jason.decode!(request.resp_body)
    end
  end
end
