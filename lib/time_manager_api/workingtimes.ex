defmodule TimeManagerApi.Workingtimes do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :start, :end, :user_id]}
  schema "workingtimes" do
    field :start, :utc_datetime
    field :end, :utc_datetime
    belongs_to :user, TimeManagerApi.User
  end

  @doc false
  def changeset(workingtimes, attrs) do
    workingtimes
    |> cast(attrs, [:start, :end, :user_id])
    |> validate_required([:start, :end, :user_id])
  end
end
