defmodule Bowling.Scoring.ValidationTest do
  use ExUnit.Case

  alias Bowling.Factory
  alias Bowling.Scoring.Validation

  doctest Bowling.Scoring.Validation

  describe "run/3" do
    test "validates the first throw in the second frame" do
      game = Factory.create_full_game_map([{1, [10]}])

      assert :ok = Validation.run(game.frames, 2, 5)
    end

    test "can not validate the second frame without the first frame" do
      assert {:error, :invalid_frame} = Validation.run([], 2, 5)
    end

    test "can not validate the the third frame without the second frame" do
      game = Factory.create_full_game_map([{1, [10]}])

      assert {:error, :invalid_frame} = Validation.run(game.frames, 3, 5)
    end

    test "can not validate the second throw if there is already a strike in this frame" do
      game = Factory.create_full_game_map([{1, [10]}])

      assert {:error, :invalid_frame} = Validation.run(game.frames, 1, 5)
    end

    test "can not validate the third throw in the fifth frame" do
      game =
        Factory.create_full_game_map([
          {1, [10]},
          {2, [5, 4]},
          {3, [2, 1]},
          {4, [5, 2]},
          {5, [5, 2]}
        ])

      assert {:error, :invalid_frame} = Validation.run(game.frames, 5, 5)
    end

    test "can validate three throws in the 10th frame in it's strike" do
      game =
        Factory.create_full_game_map([
          {1, [10]},
          {2, [5, 4]},
          {3, [2, 1]},
          {4, [5, 2]},
          {5, [5, 2]},
          {6, [0, 0]},
          {7, [2, 1]},
          {8, [5, 4]},
          {9, [5, 5]},
          {10, [10, 1]}
        ])

      assert :ok = Validation.run(game.frames, 10, 2)
    end
  end
end
