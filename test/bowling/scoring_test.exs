defmodule Bowling.ScoringTest do
  use Bowling.DataCase

  import Bowling.Factory

  alias Bowling.Scoring
  alias Bowling.Scoring.{Game, Throw}

  doctest Bowling.Scoring

  setup do
    game = insert(:game)

    {:ok, %{game: game}}
  end

  describe "start_new_game/0" do
    test "creates a new game" do
      assert {:ok, %Game{}} = Scoring.start_new_game()
    end
  end

  describe "insert_new_throw/1" do
    test "can not find a game" do
      random_uuid = Ecto.UUID.generate()

      assert {:error, :not_found} =
               Scoring.insert_new_throw(game_uuid: random_uuid, frame_number: 1, value: 5)
    end

    test "inserts first throw", %{game: game} do
      assert {:ok,
              %Throw{
                number: 0,
                value: 5
              }} = Scoring.insert_new_throw(game_uuid: game.uuid, frame_number: 1, value: 5)
    end
  end
end
