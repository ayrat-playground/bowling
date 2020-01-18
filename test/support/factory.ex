defmodule Bowling.Factory do
  use ExMachina.Ecto, repo: Bowling.Repo

  alias Bowling.Scoring.{Frame, Game, Throw}

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
