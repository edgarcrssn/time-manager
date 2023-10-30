defmodule TimeManagerApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :email, :string
      add :role, :string
      add :team_id, references(:teams, on_delete: :nothing)
    end

    create unique_index(:users, [:email])
  end
end
