defmodule Bowling.Repo.Migrations.AddBaseEntites do
  use Ecto.Migration

  def change do
    create table(:games, primary_key: false) do
      timestamps()
    end

    create table(:frames) do
      add(:game_hash, references(:games, column: :hash, on_delete: :delete_all, type: :bytea))

      timestamps()
    end

    create table(:throws) do
      add(:frame_id, references(:frames, column: :id, on_delete: :delete_all))
      add(:value, :integer, null: false)
    end
  end
end
