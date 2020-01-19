defmodule Bowling.Scoring.Game do
  use Bowling.Schema

  alias Bowling.Scoring.Frame

  @primary_key {:uuid, :binary_id, autogenerate: true}
  schema "games" do
    has_many(:frames, Frame, foreign_key: :game_uuid)

    timestamps()
  end
end
