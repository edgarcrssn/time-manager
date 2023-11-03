defmodule TimeManagerApi.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Argon2

  @derive {Jason.Encoder, only: [:id, :username, :email, :role]}
  schema "users" do
    field :username, :string
    field :email, :string
    field :role, Ecto.Enum, values: [:employee, :manager, :general_manager], default: :employee
    field :password_hash, :string
    field :password, :string, virtual: true

    belongs_to :team, TimeManagerApi.Team, foreign_key: :team_id, type: :integer

    has_one :clock, TimeManagerApi.Clock
    has_many :working_times, TimeManagerApi.WorkingTimes
    many_to_many :teams, TimeManagerApi.Team, join_through: "user_teams"
  end


  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:username, :email, :role, :password])
    |> validate_required([:username, :email, :role])
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/i)
    |> unique_constraint(:email)
    |> hash_password()
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Argon2.hash_pwd_salt(password))
      _ ->
        changeset
    end
  end
end
