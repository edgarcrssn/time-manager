defmodule TimeManagerApi.Repo.Migrations.CreateWorkingtimes do
  use Ecto.Migration

  def change do
    create table(:workingtimes) do
      add :start, :naive_datetime, null: false
      add :end, :naive_datetime, null: false
      add :hours_worked, :float
      add :night_hours_worked, :float
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:workingtimes, [:user_id])
  end
end
