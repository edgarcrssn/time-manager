defmodule TimeManagerApi.UserTeam do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :user_id, :team_id, :is_owner]}
  schema "user_teams" do
    field :user_id, :integer
    field :team_id, :integer
    field :is_owner, :boolean, default: false
  end

  def changeset(user_teams, params \\ %{}) do
    user_teams
    |> cast(params, [:user_id, :team_id, :is_owner])
    |> validate_required([:user_id, :team_id, :is_owner])
  end
end
