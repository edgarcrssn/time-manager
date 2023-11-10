defmodule TimeManagerApi.Workingtimes do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  alias TimeManagerApi.Repo

  @derive {Jason.Encoder, only: [:id, :start, :end, :user_id, :hours_worked, :night_hours_worked]}
  schema "workingtimes" do
    field :start, :utc_datetime
    field :end, :utc_datetime
    field :hours_worked, :float
    field :night_hours_worked, :float
    belongs_to :user, TimeManagerApi.User
  end

  @doc false
  def changeset(workingtimes, attrs) do
    workingtimes
    |> cast(attrs, [:start, :end, :user_id])
    |> validate_required([:start, :end, :user_id])
    |> calculate_hours_worked()
    |> calculate_night_hours_worked()
  end

  defp calculate_hours_worked(changeset) do
    case {changeset |> get_field(:start), changeset |> get_field(:end)} do
      {nil, _} ->
        changeset

      {_, nil} ->
        changeset

      {start, end_time} ->
        duration = DateTime.diff(end_time, start, :second) / 3600.0
        changeset |> put_change(:hours_worked, duration)
    end
  end

  defp calculate_night_hours_worked(changeset) do
    case {changeset |> get_field(:start), changeset |> get_field(:end)} do
      {nil, _} ->
        changeset

      {_, nil} ->
        changeset

      {start, end_time} ->
        night_hours = calculate_night_hours(start, end_time)
        changeset |> put_change(:night_hours_worked, night_hours)
    end
  end

  defp calculate_night_hours(start, end_time) do
    night_start = DateTime.new!(start |> DateTime.to_date(), Time.new!(21, 0, 0))

    night_end =
      DateTime.new!(start |> DateTime.to_date(), Time.new!(6, 0, 0)) |> DateTime.add(86400)

    adjusted_start = max(start, night_start)
    adjusted_end = min(end_time, night_end)

    if adjusted_start < adjusted_end do
      DateTime.diff(adjusted_end, adjusted_start, :second) / 3600.0
    else
      0.0
    end
  end
end
