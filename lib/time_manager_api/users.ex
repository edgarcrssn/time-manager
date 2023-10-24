defmodule TimeManagerApi.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:username, :email])
    |> validate_required([:username, :email])
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/i, message: "Email format is invalid")
  end
end
