defmodule TimeManagerApi.Repo.Migrations.AddTeamReferenceToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :team_id, references(:teams, on_delete: :delete_all)
    end

    create index(:users, [:team_id])
  end
end
