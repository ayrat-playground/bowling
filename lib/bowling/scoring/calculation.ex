defmodule Bowling.Scoring.Calculation do
  @moduledoc """
  Score calculation logic
  """

  alias Bowling.Scoring.{Game, Frame}

  @type result :: map()

  @doc """
  Calculates all frame scores for the given name. Note, that a game should have its
  associations preloaded.

  Returns a map with frams scores.

  ### Examples

     iex> game = %{
     ...>  frames: [
     ...>     %{number: 1, throws: [%{number: 0, value: 10}]},
     ...>     %{number: 2, throws: [%{number: 0, value: 5}, %{number: 1, value: 4}]},
     ...>     %{number: 3, throws: [%{number: 0, value: 2}, %{number: 1, value: 1}]}]}
     iex> Bowling.Scoring.Calculation.run(game)
     %{1 => 19, 2 => 28, 3 => 31}

  """
  @spec run(Game.t()) :: result()
  def run(game) do
    game.frames
    |> raw_frames()
    |> calculate_frame_scores()
  end

  @spec raw_frames([Frame.t()]) :: [tuple()]
  defp raw_frames(frames) do
    Enum.map(frames, fn %{number: number, throws: throws} ->
      raw_throws = Enum.map(throws, fn %{value: value} -> value end)

      {number, raw_throws}
    end)
  end

  @spec calculate_frame_scores([tuple()]) :: result()
  defp calculate_frame_scores(frames) do
    frames
    |> Enum.map(fn {number, _throws} -> {number, calculate_frame_score(number, frames)} end)
    |> Enum.into(%{})
  end

  @spec calculate_frame_score(integer(), [tuple()]) :: integer()
  defp calculate_frame_score(frame_number, frames) do
    {current_frames, future_frames} =
      Enum.split_while(frames, fn {number, _} -> number <= frame_number end)

    current_throws = Enum.flat_map(current_frames, fn {_, throws} -> throws end)

    future_throws =
      future_frames
      |> Enum.flat_map(fn {_, throws} -> throws end)
      |> Enum.slice(0, 2)

    do_calculate(current_throws, future_throws)
  end

  @spec do_calculate([integer()], [integer()], integer()) :: integer()
  defp do_calculate(current, future, acc \\ 0)

  defp do_calculate([10], future, acc) do
    case future do
      [first, second] -> acc + 10 + first + second
      [] -> acc
    end
  end

  defp do_calculate([10, first], [second | _rest] = extra, acc),
    do: do_calculate([first], extra, acc + 10 + first + second)

  defp do_calculate([10, _first], [], acc), do: acc

  defp do_calculate([first_spare, second_spare], future, acc)
       when first_spare + second_spare == 10 do
    case future do
      [] -> acc
      [future | _rest] -> acc + 10 + future
    end
  end

  defp do_calculate([first, second], _extra, acc), do: acc + first + second

  defp do_calculate([10, first, second | rest], future, acc),
    do: do_calculate([first, second | rest], future, acc + 10 + first + second)

  defp do_calculate([first_spare, second_spare, first | rest], future, acc)
       when first_spare + second_spare == 10,
       do: do_calculate([first | rest], future, acc + 10 + first)

  defp do_calculate([first, second | rest], future, acc) do
    do_calculate(rest, future, acc + first + second)
  end
end
