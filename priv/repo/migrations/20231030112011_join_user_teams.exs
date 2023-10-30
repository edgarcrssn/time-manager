defmodule TimeManagerApi.Repo.Migrations.JoinUserTeams do
  use Ecto.Migration

  def change do
    create table(:user_teams) do
      add :user_id, references(:users)
      add :team_id, references(:teams)
      add :is_owner, :boolean
    end

    create unique_index(:user_teams, [:user_id, :team_id])
  end
end
