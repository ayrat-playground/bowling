defmodule Bowling.Scoring.Frame do
  @moduledoc """
  Represent a frame of a bowling game.
  """

  use Bowling.Schema

  alias Bowling.Scoring.{Game, Throw}

  @derive {Jason.Encoder, only: [:game_uuid, :game, :throws, :number]}

  @type t :: %Bowling.Scoring.Frame{
          id: integer(),
          game_uuid: Ecto.UUID.t(),
          game: Game.t() | %Ecto.Association.NotLoaded{},
          throws: [Throw.t()] | %Ecto.Association.NotLoaded{},
          number: integer(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

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
