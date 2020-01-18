defmodule Bowling.Schema do
  @moduledoc "Common configuration for schemas."

  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema

      import Ecto.{Changeset, Query}

      @timestamps_opts [type: :utc_datetime_usec]
    end
  end
end
