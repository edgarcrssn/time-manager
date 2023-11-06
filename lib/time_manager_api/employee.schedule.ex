defmodule TimeManagerApi.EmployeeSchedule do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :monday, :tuesday, :wednesday, :thursday, :saturday, :sunday, :start_time, :end_time]}
  schema "employee_schedule" do
    belongs_to :user, TimeManagerApi.User

    field :monday, :boolean
    field :tuesday, :boolean
    field :wednesday, :boolean
    field :thursday, :boolean
    field :friday, :boolean
    field :saturday, :boolean
    field :sunday, :boolean
    field :start_time, :time
    field :end_time, :time
  end

  @doc false
  def changeset(schedule, attrs) do
    schedule
    |> cast(attrs, [:user_id, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :start_time, :end_time])
    |> validate_required([:user_id, :start_time, :end_time])
    |> unique_constraint(:user_id, name: "employee_schedule_user_id_index")
  end
end
