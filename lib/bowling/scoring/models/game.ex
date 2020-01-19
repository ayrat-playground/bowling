defmodule Bowling.Scoring.Game do
  @moduledoc """
  A package of data that contains zero or more frames, idetified by uuid.
  It represent a bowling game.
  """
  use Bowling.Schema

  alias Bowling.Scoring.Frame

  @derive {Jason.Encoder, only: [:uuid, :frames]}

  @type t :: %Bowling.Scoring.Game{
          uuid: Ecto.UUID.t(),
          frames: [Frame.t()] | %Ecto.Association.NotLoaded{},
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:uuid, :binary_id, autogenerate: true}
  schema "games" do
    has_many(:frames, Frame, foreign_key: :game_uuid)

    timestamps()
  end
end

defimpl Phoenix.Param, for: Bowling.Scoring.Game do
  def to_param(%{uuid: uuid}) do
    "#{uuid}"
  end
end
