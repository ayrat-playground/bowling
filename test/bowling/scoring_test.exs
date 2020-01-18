defmodule Bowling.ScoringTest do
  use Bowling.DataCase

  import Bowling.Factory

  alias Bowling.Scoring
  alias Bowling.Scoring.{Game, Frame, Throw}

  describe "start_new_game/0" do
    test "creates a new game" do
      assert {:ok, %Game{}} = Scoring.start_new_game()
    end
  end

  describe "insert_new_throw/1" do
    test "can not find a game" do
      random_uuid = Ecto.UUID.generate()

      assert {:error, :not_found} = Scoring.insert_new_throw(game_uuid: random_uuid, frame_number: 1, value: 5)
    end

    test "inserts first throw" do
      game = insert(:game)

      assert {:ok,
             %Throw{
               number: 0,
               value: 5
             }} = Scoring.insert_new_throw(game_uuid: game.uuid, frame_number: 1, value: 5)
    end

    test "inserts the second throw in the second frame" do
      game = insert(:game)
      first_frame = insert(:frame, game: game, number: 1)
      insert(:throw, frame: first_frame, value: 10, number: 0)

      assert {:ok,
              %Throw{
                number: 0,
                value: 5
              }} = Scoring.insert_new_throw(game_uuid: game.uuid, frame_number: 2, value: 5)
    end

    test "can not insert the second frame without the first frame" do
      game = insert(:game)

      assert {:error, :invalid_frame} = Scoring.insert_new_throw(game_uuid: game.uuid, frame_number: 2, value: 5)
    end

    test "can not insert the the third frame without the second frame" do
      game = insert(:game)
      first_frame = insert(:frame, game: game, number: 1)
      insert(:throw, frame: first_frame, value: 10, number: 0)

      assert {:error, :invalid_frame} = Scoring.insert_new_throw(game_uuid: game.uuid, frame_number: 3, value: 5)
    end
  end
end
