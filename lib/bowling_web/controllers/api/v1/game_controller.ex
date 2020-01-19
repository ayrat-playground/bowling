defmodule BowlingWeb.API.V1.GameController do
  use BowlingWeb, :controller

  import BowlingWeb.Gettext

  alias Bowling.Scoring
  alias Ecto.UUID

  def create(conn, _params) do
    {:ok, game} = Scoring.start_new_game()

    send_resp(conn, :created, Jason.encode!(game))
  end

  def score(conn, %{"game_id" => game_uuid}) do
    with {:ok, uuid} <- parse_uuid(game_uuid),
         {:ok, score} <- Scoring.calculate_score(uuid) do
      send_resp(conn, :ok, Jason.encode!(score))
    else
      error -> send_error(conn, error)
    end
  end

  def score(conn, _params) do
    send_error(conn, {:error, :no_uuid})
  end

  defp parse_uuid(game_uuid) do
    case UUID.cast(game_uuid) do
      :error -> {:error, :invalid_uuid}
      {:ok, uuid} -> {:ok, uuid}
    end
  end

  defp send_error(conn, error) do
    {code, message} =
      case error do
        {:error, :invalid_uuid} ->
          {:bad_request, gettext("Provided uuid is not valid")}

        {:error, :not_found} ->
          {:not_found, gettext("The game with specified uuid is not found")}

        {:error, :no_uuid} ->
          {:bad_request, gettext("UUID is not provided")}
      end

    send_resp(conn, code, Jason.encode!(%{error: message}))
  end
end
