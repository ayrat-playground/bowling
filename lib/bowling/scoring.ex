defmodule Bowling.Scoring do
  @moduledoc """
  Scoring context.
  """

  import Ecto.Query, only: [from: 2]

  alias Bowling.Repo
  alias Bowling.Scoring.{Game, Frame, Throw, Validation}

  def start_new_game do
    Repo.insert(%Game{})
  end

  def insert_new_throw(game_uuid: game_uuid, frame_number: frame_number, value: value) do
    with {:ok, game} <- fetch_game(game_uuid),
         :ok <- Validation.execute(game.frames, frame_number, value) do
      thrw = do_insert_throw(game, frame_number, value)

      thrw
    else
      {:error, :not_found} -> {:error, :not_found}
      {:error, :invalid_frame} -> {:error, :invalid_frame}
    end
  end

  defp do_insert_throw(game, frame_number, value) do
    last_frame = List.last(game.frames)

    if Validation.previous_frame_complete?(last_frame) do
      Repo.transaction(fn ->
        frame = create_new_frame!(game, frame_number)
        create_new_throw!(frame, value)
      end)
    else
      frame = List.last(game.frames)

      create_new_throw!(frame, value)
    end
  end

  defp create_new_frame!(game, frame_number) do
    frame_changeset = Frame.changeset(%Frame{}, %{game_uuid: game.uuid, number: frame_number})

    result = Repo.insert!(frame_changeset)
    %{result | throws: []}
  end

  defp create_new_throw!(frame, value) do
    last_throw = List.last(frame.throws)
    throw_number = (last_throw && last_throw.number + 1) || 0

    throw_changeset =
      Throw.changeset(%Throw{}, %{frame_id: frame.id, number: throw_number, value: value})

    Repo.insert!(throw_changeset)
  end

  defp fetch_game(game_uuid) do
    throw_query = from(t in Throw, order_by: [asc: :number])
    frame_query = from(f in Frame, order_by: [asc: :number], preload: [throws: ^throw_query])

    query =
      from(
        game in Game,
        where: game.uuid == ^game_uuid,
        preload: [frames: ^frame_query]
      )

    case Repo.one(query) do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end
end
