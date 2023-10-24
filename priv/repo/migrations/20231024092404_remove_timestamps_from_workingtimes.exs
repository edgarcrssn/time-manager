defmodule TimeManagerApi.Repo.Migrations.RemoveTimestampsFromWorkingtimes do
  use Ecto.Migration

  def change do
    alter table(:workingtimes) do
      remove :inserted_at
      remove :updated_at
    end
  end
end
