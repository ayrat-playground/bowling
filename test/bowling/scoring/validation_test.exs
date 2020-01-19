defmodule Bowling.Scoring.ValidationTest do
  use ExUnit.Case

  alias Bowling.Factory
  alias Bowling.Scoring.Validation

  describe "execute/3" do
    test "validates the first throw in the second frame" do
      game = Factory.create_full_game_map([{1, [10]}])

      assert :ok = Validation.execute(game.frames, 2, 5)
    end

    test "can not validate the second frame without the first frame" do
      assert {:error, :invalid_frame} = Validation.execute([], 2, 5)
    end

    test "can not validate the the third frame without the second frame" do
      game = Factory.create_full_game_map([{1, [10]}])

      assert {:error, :invalid_frame} = Validation.execute(game.frames, 3, 5)
    end

    test "can not insert the second throw if there is already a strike in this frame" do
      game = Factory.create_full_game_map([{1, [10]}])

      assert {:error, :invalid_frame} = Validation.execute(game.frames, 1, 5)
    end
  end
end
