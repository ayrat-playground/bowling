defmodule Bowling.Scoring.Throw do
  use Bowling.Schema

  alias Bowling.Scoring.Frame

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