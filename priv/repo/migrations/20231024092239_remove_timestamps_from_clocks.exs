defmodule TimeManagerApi.Repo.Migrations.RemoveTimestampsFromClocks do
  use Ecto.Migration

  def change do
    alter table(:clocks) do
      remove :inserted_at
      remove :updated_at
    end
  end
end
