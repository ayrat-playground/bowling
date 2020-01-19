defmodule Bowling.Factory do
  @moduledoc """
  Factory for test data
  """
  use ExMachina.Ecto, repo: Bowling.Repo

  alias Bowling.Scoring.{Frame, Game, Throw}

  def create_full_game_map(frames) do
    formatted_frames =
      Enum.map(frames, fn {frame_number, throws} ->
        throws_map =
          throws
          |> Enum.with_index()
          |> Enum.map(fn {value, index} ->
            %{number: index, value: value}
          end)

        %{number: frame_number, throws: throws_map}
      end)

    %{frames: formatted_frames}
  end

  def game_factory do
    %Game{}
  end

  def frame_factory do
    %Frame{
      number: random_number(),
      game: build(:game)
    }
  end

  def throw_factory do
    %Throw{
      value: random_number(),
      number: random_number(2),
      frame: build(:frame)
    }
  end

  defp random_number(val \\ 10) do
    :rand.uniform(val)
  end
end
