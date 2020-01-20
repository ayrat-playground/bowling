defmodule BowlingWeb.Router do
  use BowlingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", BowlingWeb.API.V1, as: :api_v1 do
    pipe_through :api

    resources("/games", GameController, only: [:create]) do
      get("/score", GameController, :score, as: :score)

      resources("/frames", FrameController, only: []) do
        resources("/throws", ThrowController, only: [:create])
      end
    end
  end
end
