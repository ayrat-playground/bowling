defmodule Bowling.Repo.Migrations.AddBaseEntites do
  use Ecto.Migration

  def change do
    create table(:games, primary_key: false) do
      add(:uuid, :bytea, null: false, primary_key: true)

      timestamps()
    end

    create table(:frames) do
      add(:game_uuid, references(:games, column: :uuid, on_delete: :delete_all, type: :bytea))
      add(:number, :integer, null: false)

      timestamps()
    end

    create table(:throws) do
      add(:frame_id, references(:frames, column: :id, on_delete: :delete_all))
      add(:value, :integer, null: false)
      add(:number, :integer, null: false)

      timestamps()
    end

    create unique_index(:frames, [:game_uuid, :number])
    create unique_index(:throws, [:frame_id, :number])

    create(
      constraint(
        :throws,
        :throws_value,
        check: """
        value >= 0 and value <= 10
        """
      )
    )

    create(
      constraint(
        :frames,
        :frame_number,
        check: """
        number >= 1 and number <= 10
        """
      )
    )
  end
end
