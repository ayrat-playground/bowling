defmodule Bowling.Scoring.CalculationTest do
  use ExUnit.Case

  alias Bowling.Factory
  alias Bowling.Scoring.Calculation

  doctest Bowling.Scoring.Calculation

  describe "run/1" do
    test "calculate score" do
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
          {10, [10, 1, 2]}
        ])

      expected_result = %{
        1 => 19,
        2 => 28,
        3 => 31,
        4 => 38,
        5 => 45,
        6 => 45,
        7 => 48,
        8 => 57,
        9 => 77,
        10 => 93
      }

      assert expected_result == Calculation.run(game)
    end

    test "calculates score with all strikes" do
      game =
        Factory.create_full_game_map([
          {1, [10]},
          {2, [10]},
          {3, [10]},
          {4, [10]},
          {5, [10]},
          {6, [10]},
          {7, [10]},
          {8, [10]},
          {9, [10]},
          {10, [10, 1, 5]}
        ])

      expected_result = %{
        1 => 30,
        2 => 60,
        3 => 90,
        4 => 120,
        5 => 150,
        6 => 180,
        7 => 210,
        8 => 240,
        9 => 261,
        10 => 283
      }

      assert expected_result == Calculation.run(game)
    end

    test "calculate score with all spares" do
      game =
        Factory.create_full_game_map([
          {1, [1, 9]},
          {2, [2, 8]},
          {3, [3, 7]},
          {4, [4, 6]},
          {5, [5, 5]},
          {6, [6, 4]},
          {7, [7, 3]},
          {8, [8, 2]},
          {9, [9, 1]},
          {10, [9, 1, 10]}
        ])

      expected_result = %{
        1 => 12,
        2 => 25,
        3 => 39,
        4 => 54,
        5 => 70,
        6 => 87,
        7 => 105,
        8 => 124,
        9 => 143,
        10 => 163
      }

      assert expected_result == Calculation.run(game)
    end
  end
end
