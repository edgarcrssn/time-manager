defmodule TimeManagerApi.Team do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name]}
  schema "teams" do
    field :name, :string
    belongs_to :manager, TimeManagerApi.User

    timestamps()
  end

  def changeset(team, params \\ %{}) do
    team
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
