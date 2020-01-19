defmodule BowlingWeb.API.V1.ThrowController do
  use BowlingWeb, :controller

  import BowlingWeb.ErrorHandler

  alias Ecto.UUID
  alias Bowling.Scoring

  def create(conn, params) do
    with {:ok, create_params} <- validate_params(params),
         {:ok, thrw} <- Scoring.insert_new_throw(create_params) do
      send_resp(conn, :created, Jason.encode!(thrw))
    else
      error -> send_error(conn, error)
    end
  end

  defp validate_params(%{"game_id" => game_uuid, "frame_id" => frame_number, "value" => value}) do
    with {:ok, uuid} <- parse_uuid(game_uuid),
         {:ok, integer_frame_number} <- parse_integer(frame_number),
         {:ok, integer_value} <- parse_integer(value) do
      {:ok, [game_uuid: uuid, frame_number: integer_frame_number, value: integer_value]}
    end
  end

  defp validate_params(_) do
    {:error, :no_value}
  end

  defp parse_integer(string) when is_binary(string) do
    case Integer.parse(string) do
      {value, ""} -> {:ok, value}
      _ -> {:error, :not_integer}
    end
  end

  defp parse_integer(int) when is_integer(int), do: {:ok, int}

  defp parse_uuid(game_uuid) do
    case UUID.cast(game_uuid) do
      :error -> {:error, :invalid_uuid}
      {:ok, uuid} -> {:ok, uuid}
    end
  end
end
