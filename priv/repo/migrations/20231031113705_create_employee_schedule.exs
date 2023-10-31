defmodule TimeManagerApi.Repo.Migrations.CreateEmployeeSchedule do
  use Ecto.Migration

  def change do
    create table(:employee_schedule) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :monday, :boolean, default: false
      add :tuesday, :boolean, default: false
      add :wednesday, :boolean, default: false
      add :thursday, :boolean, default: false
      add :friday, :boolean, default: false
      add :saturday, :boolean, default: false
      add :sunday, :boolean, default: false
      add :start_time, :time
      add :end_time, :time
    end

    create unique_index(:employee_schedule, [:user_id])
  end
end
