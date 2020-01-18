defmodule Bowling.Scoring.Frame do
  use Bowling.Schema

  alias Bowling.Scoring.{Game, Throw}

  schema "frames" do
    belongs_to(:game, Game, foreign_key: :game_uuid, references: :uuid, type: Ecto.UUID)
    has_many(:throws, Throw)
    field(:number, :integer)

    timestamps()
  end

  def changeset(frame, params \\ %{}) do
    frame
    |> cast(params, [:game_uuid, :number])
    |> validate_required([:game_uuid, :number])
    |> foreign_key_constraint(:game_uuid)
  end
end
