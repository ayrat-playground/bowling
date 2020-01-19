defmodule Bowling.Scoring do
  @moduledoc """
  Scoring context.
  """

  import Ecto.Query, only: [from: 2]

  alias Bowling.Repo
  alias Bowling.Scoring.{Calculation, Game, Frame, Throw, Validation}

  @doc """
  Creates a new game.

  ## Examples

      iex> with {:ok, %Bowling.Scoring.Game{}} <- Bowling.Scoring.start_new_game(), do: :ok
      :ok
  """

  @spec start_new_game() :: {:ok, Game.t()}
  def start_new_game do
    {:ok, game} = Repo.insert(%Game{})

    {:ok, %{game | frames: []}}
  end

  @doc """
  Validates and insertes the give throw `value` for the specified `frame_number` for the
  given `game_uuid`.

  Returns created throw on success.
  If the game can not be found returns `{:error, :not_found}`. If throw is not valid, returns {:error, :invalid_frame}

  ## Examples

      iex> Bowling.Scoring.insert_new_throw(game_uuid: Ecto.UUID.generate, frame_number: 1, value: 10)
      {:error, :not_found}

      iex> Bowling.Scoring.insert_new_throw(game_uuid: insert(:game).uuid, frame_number: 10, value: 10)
      {:error, :invalid_frame}

      iex> with  {:ok, %Bowling.Scoring.Throw{number: 0, value: 10}} <- Bowling.Scoring.insert_new_throw(game_uuid: insert(:game).uuid, frame_number: 1, value: 10), do: :ok
      :ok
  """

  @spec insert_new_throw(Keyword.t()) ::
          {:ok, Throw.t()} | {:error, :not_found} | {:error, :invalid_frame}
  def insert_new_throw(game_uuid: game_uuid, frame_number: frame_number, value: value) do
    with {:ok, game} <- fetch_game(game_uuid),
         :ok <- Validation.run(game.frames, frame_number, value) do
      do_insert_throw(game, frame_number, value)
    end
  end

  @doc """
  Calculates score for each frame for the given `game_uuid`.

  Returns `{:ok, scores_map}` on success, `{:error, :not_found}` if the game is not found.

  ## Examples

      iex> Bowling.Scoring.calculate_score(Ecto.UUID.generate)
      {:error, :not_found}

      iex> game = insert(:game)
      iex> Bowling.Scoring.insert_new_throw(game_uuid: game.uuid, frame_number: 1, value: 5)
      iex> Bowling.Scoring.insert_new_throw(game_uuid: game.uuid, frame_number: 1, value: 2)
      iex> Bowling.Scoring.calculate_score(game.uuid)
      {:ok, %{1 => 7}}
  """

  @spec calculate_score(Ecto.UUID.t()) :: {:ok, Calculation.result()} | {:error, :not_found}
  def calculate_score(game_uuid) do
    case fetch_game(game_uuid) do
      {:ok, game} -> {:ok, Calculation.run(game)}
      error -> error
    end
  end

  @spec do_insert_throw(Game.t(), integer(), integer()) :: {:ok, Throw.t()}
  defp do_insert_throw(game, frame_number, value) do
    last_frame = List.last(game.frames)

    if Validation.frame_complete?(last_frame) do
      Repo.transaction(fn ->
        frame = create_new_frame!(game, frame_number)
        create_new_throw!(frame, value)
      end)
    else
      frame = List.last(game.frames)

      create_new_throw!(frame, value)
    end
  end

  @spec create_new_frame!(Game.t(), integer()) :: Frame.t()
  defp create_new_frame!(game, frame_number) do
    frame_changeset = Frame.changeset(%Frame{}, %{game_uuid: game.uuid, number: frame_number})

    result = Repo.insert!(frame_changeset)
    %{result | throws: []}
  end

  @spec create_new_frame!(Frame.t(), integer()) :: Throw.t()
  defp create_new_throw!(frame, value) do
    last_throw = List.last(frame.throws)
    throw_number = (last_throw && last_throw.number + 1) || 0

    throw_changeset =
      Throw.changeset(%Throw{}, %{frame_id: frame.id, number: throw_number, value: value})

    Repo.insert!(throw_changeset)
  end

  @spec fetch_game(Ecto.UUID.t()) :: {:ok, Game.t()} | {:error, :not_found}
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
