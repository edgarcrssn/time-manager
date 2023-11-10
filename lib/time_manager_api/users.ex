defmodule TimeManagerApi.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Argon2

  @derive {Jason.Encoder,
           only: [
             :id,
             :username,
             :email,
             :role,
             :hourly_rate,
             :night_hourly_rate,
             :additional_hourly_rate,
             :additional_hours,
             :night_hours,
             :gross_hourly_rate,
             :gross_night_hourly_rate,
             :gross_additional_hourly_rate
           ]}
  schema "users" do
    field :firstname, :string
    field :lastname, :string
    field :username, :string
    field :email, :string
    field :role, Ecto.Enum, values: [:employee, :manager, :general_manager], default: :employee
    field :password_hash, :string
    field :hourly_rate, :float
    field :night_hourly_rate, :float
    field :additional_hourly_rate, :float
    field :additional_hours, :float, default: 0.0
    field :night_hours, :float, default: 0.0
    field :paid_leave_balance, :float, default: 0.0
    field :gross_hourly_rate, :float
    field :gross_night_hourly_rate, :float
    field :gross_additional_hourly_rate, :float
    belongs_to :team, TimeManagerApi.Team, foreign_key: :team_id, type: :integer

    has_one :clock, TimeManagerApi.Clock
    has_many :working_times, TimeManagerApi.Workingtimes
    many_to_many :teams, TimeManagerApi.Team, join_through: "user_teams"
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [
      :firstname,
      :lastname,
      :username,
      :email,
      :role,
      :hourly_rate,
      :additional_hourly_rate,
      :night_hourly_rate,
      :additional_hours,
      :night_hours,
      :paid_leave_balance,
      :gross_hourly_rate,
      :gross_night_hourly_rate,
      :gross_additional_hourly_rate
    ])
    |> validate_required([:username, :email, :role])
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/i)
    |> unique_constraint(:email)
    |> hash_password()
    |> set_hourly_rate_based_on_role()
    |> set_additional_rates()
    |> set_hourly_rate_based_on_role()
    |> set_additional_rates()
    |> set_gross_rates()
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Argon2.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end

  defp set_hourly_rate_based_on_role(changeset) do
    case get_change(changeset, :hourly_rate) do
      nil ->
        role = get_field(changeset, :role)

        hourly_rate =
          case role do
            :employee -> 12.00
            :manager -> 27.47
            :general_manager -> 28.3
            _ -> get_field(changeset, :hourly_rate) || 0.0
          end

        put_change(changeset, :hourly_rate, hourly_rate)

      _hourly_rate ->
        changeset
    end
  end

  defp set_additional_rates(changeset) do
    change_or_default = fn field, default ->
      get_change(changeset, field, get_field(changeset, field) || default)
    end

    hourly_rate = change_or_default.(:hourly_rate, 0.0)

    new_values = %{
      night_hourly_rate: hourly_rate * 1.5,
      additional_hourly_rate: hourly_rate * 2
    }

    changeset
    |> put_change(:night_hourly_rate, new_values.night_hourly_rate)
    |> put_change(:additional_hourly_rate, new_values.additional_hourly_rate)
  end

  defp set_gross_rates(changeset) do
    hourly_rate = get_field(changeset, :hourly_rate)

    gross_hourly_rate = calculate_gross_rate(hourly_rate)
    gross_night_hourly_rate = calculate_gross_rate(hourly_rate * 1.5)
    gross_additional_hourly_rate = calculate_gross_rate(hourly_rate * 2)

    changeset
    |> put_change(:gross_hourly_rate, gross_hourly_rate)
    |> put_change(:gross_night_hourly_rate, gross_night_hourly_rate)
    |> put_change(:gross_additional_hourly_rate, gross_additional_hourly_rate)
  end

  defp calculate_gross_rate(net_rate) do
    net_rate * 1.22
  end
end
