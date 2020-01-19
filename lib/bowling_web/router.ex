defmodule BowlingWeb.Router do
  use BowlingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BowlingWeb.API.V1, as: :api_v1 do
    pipe_through :api

    resources("/", GameController, only: [:create]) do
      get("/score", GameController, :score, as: :score)
    end
  end
end
