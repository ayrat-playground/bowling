defmodule Bowling.Scoring.Throw do
  @moduledoc """
  Represent a throw in a bowling game.
  """
  use Bowling.Schema

  alias Bowling.Scoring.Frame

  @type t :: %Bowling.Scoring.Throw{
          id: integer(),
          frame_id: integer(),
          frame: Frame.t() | %Ecto.Association.NotLoaded{},
          value: integer(),
          number: integer(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "throws" do
    belongs_to(:frame, Frame, foreign_key: :frame_id, references: :id)
    field(:value, :integer)
    field(:number, :integer)

    timestamps()
  end

  def changeset(thrw, params \\ %{}) do
    thrw
    |> cast(params, [:value, :number, :frame_id])
    |> validate_required([:value, :number, :frame_id])
    |> foreign_key_constraint(:frame_id)
  end
end
