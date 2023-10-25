defmodule TimeManagerApi.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :username, :email, :role]}
  schema "users" do
    field :username, :string
    field :email, :string
    field :role, Ecto.Enum, values: [:employee, :manager, :general_manager]
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:username, :email, :role])
    |> validate_required([:username, :email, :role])
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/i)
    |> unique_constraint(:email)
  end
end
