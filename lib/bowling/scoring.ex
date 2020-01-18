defmodule Bowling.Scoring do
  @moduledoc """
  Scoring context.
  """

  import Ecto.Query, only: [from: 2]

  alias Bowling.Repo
  alias Bowling.Scoring.{Game, Frame, Throw}

  def start_new_game do
    Repo.insert(%Game{})
  end

  def insert_new_throw(game_uuid: game_uuid, frame_number: frame_number, value: value) do
    with {:ok, game} <- fetch_game(game_uuid),
         :ok <- validate_frame(game.frames, frame_number, value) do
        thrw = do_insert_throw(game, frame_number, value)

        thrw
      else
        {:error, :not_found} -> {:error, :not_found}
        {:error, :invalid_frame} -> {:error, :invalid_frame}
    end
  end

  defp do_insert_throw(game, frame_number, value) do
    last_frame = List.last(game.frames)

    if previous_frame_complete?(last_frame) do
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

    throw_changeset = Throw.changeset(%Throw{}, %{frame_id: frame.id, number: throw_number, value: value})

    Repo.insert!(throw_changeset)
  end


  defp validate_frame([], 1, _value), do: :ok

  defp validate_frame([], _, _value), do: {:error, :invalid_frame}

  defp validate_frame(frames, frame_number, value) do
    last_frame = List.last(frames)

    cond do
      last_frame.number == frame_number && eligible_for_current_frame?(last_frame, frame_number, value) -> :ok
      last_frame.number + 1 == frame_number && previous_frame_complete?(last_frame) -> :ok
      true -> {:error, :invalid_frame}
    end
  end

  defp eligible_for_current_frame?(last_frame, frame_number, value) when frame_number == 10 do
    throw_count = Enum.count(last_frame.throws)

    cond do
      throw_count == 1 -> true
      throw_count == 2 ->
        cond do
          Enum.at(last_frame.throws, 0).value == 10 && (Enum.at(last_frame.throws, 1).value + value) <= 10 -> true
          Enum.at(last_frame.throws, 0).value + Enum.at(last_frame.throws, 1).value == 10 -> true
          true -> false
        end

      true -> false
    end
  end

  defp eligible_for_current_frame?(last_frame, _frame_number, value) do
    first_throw = Enum.at(last_frame.throws, 0)

    Enum.count(last_frame.throws) == 1 && first_throw.value + value <= 10
  end

  defp previous_frame_complete?(nil), do: true

  defp previous_frame_complete?(last_frame) do
    first_throw = Enum.at(last_frame.throws, 0)
    throw_count = Enum.count(last_frame.throws)

    (throw_count == 1 && first_throw.value == 10) || throw_count == 2
  end

  defp fetch_game(game_uuid) do
    throw_query = from(t in Throw, order_by: [asc: :number])
    frame_query = from(f in Frame, order_by: [asc: :number], preload: [throws: ^throw_query])

    query = from(
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
