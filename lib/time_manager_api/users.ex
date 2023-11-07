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
             :night_hours
           ]}
  schema "users" do
    field :username, :string
    field :email, :string
    field :role, Ecto.Enum, values: [:employee, :manager, :general_manager], default: :employee
    field :password_hash, :string
    field :password, :string, virtual: true
    field :hourly_rate, :float
    field :night_hourly_rate, :float
    field :additional_hourly_rate, :float
    field :additional_hours, :float, default: 0.0
    field :night_hours, :float, default: 0.0
    field :paid_leave_balance, :float, default: 0.0
    belongs_to :team, TimeManagerApi.Team, foreign_key: :team_id, type: :integer

    has_one :clock, TimeManagerApi.Clock
    has_many :working_times, TimeManagerApi.Workingtimes
    many_to_many :teams, TimeManagerApi.Team, join_through: "user_teams"
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [
      :username,
      :email,
      :role,
      :hourly_rate,
      :additional_hourly_rate,
      :night_hourly_rate,
      :additional_hours,
      :night_hours,
      :paid_leave_balance
    ])
    |> validate_required([:username, :email, :role])
    |> validate_format(:email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/i)
    |> unique_constraint(:email)
    |> hash_password()
    |> set_hourly_rate_based_on_role()
    |> set_additional_rates()
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
end
