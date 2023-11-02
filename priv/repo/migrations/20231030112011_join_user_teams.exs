defmodule TimeManagerApi.Repo.Migrations.JoinUserTeams do
  use Ecto.Migration

  def change do
    create table(:user_teams, primary_key: true) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :team_id, references(:teams, on_delete: :delete_all)
      add :is_owner, :boolean, on_delete: :delete_all
    end
  end
end
