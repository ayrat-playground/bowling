defmodule Bowling.Scoring.Game do
  @moduledoc """
  A package of data that contains zero or more frames, idetified by uuid.
  It represent a bowling game.
  """
  use Bowling.Schema

  alias Bowling.Scoring.Frame

  @primary_key {:uuid, :binary_id, autogenerate: true}
  schema "games" do
    has_many(:frames, Frame, foreign_key: :game_uuid)

    timestamps()
  end
end
