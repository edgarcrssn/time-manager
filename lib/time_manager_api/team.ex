defmodule TimeManagerApi.Team do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name]}
  schema "teams" do
    field :name, :string
    many_to_many :users, TimeManagerApi.Team, join_through: "user_teams"
  end

  def changeset(team, params \\ %{}) do
    team
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
