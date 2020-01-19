defmodule BowlingWeb.ErrorHandler do
  @moduledoc """
  Common error handling helpers.
  """

  import BowlingWeb.Gettext

  alias Plug.Conn

  def send_error(conn, error) do
    {code, message} =
      case error do
        {:error, :invalid_uuid} ->
          {:bad_request, gettext("Provided uuid is not valid")}

        {:error, :not_found} ->
          {:not_found, gettext("The game with specified uuid is not found")}

        {:error, :no_uuid} ->
          {:bad_request, gettext("UUID is not provided")}

        {:error, :invalid_frame} ->
          {:unprocessable_entity, gettext("Frame is not valid. It doesn't satisfy game logic")}

        {:error, :no_value} ->
          {:unprocessable_entity, gettext("Value is not provided")}

        {:error, :not_integer} ->
          {:unprocessable_entity, gettext("Type of Value or frame is not valid")}
      end

    Conn.send_resp(conn, code, Jason.encode!(%{error: message}))
  end
end
