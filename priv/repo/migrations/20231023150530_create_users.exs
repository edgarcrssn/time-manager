defmodule TimeManagerApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string
      add :role, :string
      add :password_hash, :string
      add :hourly_rate, :float
      add :night_hourly_rate, :float
      add :additional_hourly_rate, :float
      add :additional_hours, :float
      add :night_hours, :float
      add :paid_leave_balance, :float
      add :team_id, references(:teams, on_delete: :nothing)
    end

    create unique_index(:users, [:email])
  end
end
