defmodule BowlingWeb.API.V1.GameController do
  use BowlingWeb, :controller

  alias Bowling.Scoring

  def create(conn, _params) do
    {:ok, game} = Scoring.start_new_game()

    send_resp(conn, :created, Jason.encode!(game))
  end
end
