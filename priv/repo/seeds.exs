# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TimeManagerApi.Repo.insert!(%TimeManagerApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Argon2

defmodule SeedHelper do
  def hash_password(plain_text_password) do
    Argon2.hash_pwd_salt(plain_text_password)
  end
end

# User and Teams
user1 =
  TimeManagerApi.Repo.insert!(%TimeManagerApi.User{
    username: "user1",
    email: "user1@example.com",
    role: :manager,
    password_hash: SeedHelper.hash_password("azerty")
  })

user2 =
  TimeManagerApi.Repo.insert!(%TimeManagerApi.User{
    username: "user2",
    email: "user2@example.com",
    role: :employee,
    password_hash: SeedHelper.hash_password("azerty")
  })

user3 =
  TimeManagerApi.Repo.insert!(%TimeManagerApi.User{
    username: "user3",
    email: "user3@example.com",
    role: :employee,
    password_hash: SeedHelper.hash_password("azerty")
  })

user4 =
  TimeManagerApi.Repo.insert!(%TimeManagerApi.User{
    username: "user4",
    email: "user4@example.com",
    role: :manager,
    password_hash: SeedHelper.hash_password("azerty")
  })

user5 =
  TimeManagerApi.Repo.insert!(%TimeManagerApi.User{
    username: "user5",
    email: "user5@example.com",
    role: :employee,
    password_hash: SeedHelper.hash_password("azerty")
  })

user6 =
  TimeManagerApi.Repo.insert!(%TimeManagerApi.User{
    username: "user6",
    email: "user6@example.com",
    role: :employee,
    password_hash: SeedHelper.hash_password("azerty")
  })

user7 =
  TimeManagerApi.Repo.insert!(%TimeManagerApi.User{
    username: "user7",
    email: "user7@example.com",
    role: :employee,
    password_hash: SeedHelper.hash_password("azerty")
  })

general_manager =
  TimeManagerApi.Repo.insert!(%TimeManagerApi.User{
    username: "general_manager",
    email: "gm@example.com",
    role: :general_manager,
    password_hash: SeedHelper.hash_password("azerty")
  })

team1 = TimeManagerApi.Repo.insert!(%TimeManagerApi.Team{name: "Team1"})
team2 = TimeManagerApi.Repo.insert!(%TimeManagerApi.Team{name: "Team2"})

user_team1 =
  TimeManagerApi.Repo.insert!(%TimeManagerApi.UserTeam{user: user1, team: team1, is_owner: true})

user_team2 =
  TimeManagerApi.Repo.insert!(%TimeManagerApi.UserTeam{user: user4, team: team2, is_owner: true})

user_team3 =
  TimeManagerApi.Repo.insert!(%TimeManagerApi.UserTeam{user: user5, team: team2, is_owner: false})

user_team4 =
  TimeManagerApi.Repo.insert!(%TimeManagerApi.UserTeam{user: user6, team: team2, is_owner: false})

# working times
current_date = Date.utc_today()

days_until_monday =
  cond do
    Date.day_of_week(current_date) == 1 -> 0
    true -> 1 - Date.day_of_week(current_date) + 7
  end

next_monday = Date.add(current_date, days_until_monday)

for day <- 0..4 do
  date = Date.add(next_monday, day)

  {:ok, morning_time} = Time.new(9, 0, 0)
  {:ok, evening_time} = Time.new(17, 0, 0)

  start_time = DateTime.new!(date, morning_time, "Etc/UTC")
  end_time = DateTime.new!(date, evening_time, "Etc/UTC")

  TimeManagerApi.Repo.insert!(%TimeManagerApi.Workingtimes{
    start: start_time,
    end: end_time,
    user_id: user5.id
  })
end

# clocks
TimeManagerApi.Repo.insert!(%TimeManagerApi.Clock{
  status: false,
  time: NaiveDateTime.truncate(DateTime.to_naive(DateTime.utc_now()), :second),
  user_id: user1.id
})

TimeManagerApi.Repo.insert!(%TimeManagerApi.Clock{
  status: true,
  time: NaiveDateTime.truncate(DateTime.to_naive(DateTime.utc_now()), :second),
  user_id: user2.id
})

TimeManagerApi.Repo.insert!(%TimeManagerApi.Clock{
  status: false,
  time: NaiveDateTime.truncate(DateTime.to_naive(DateTime.utc_now()), :second),
  user_id: user3.id
})

# Additional hourly_rates

users = [
  {user1, 15.00, 22.50, 30.00},
  {user2, 12.00, 18.00, 24.00},
  {user3, 12.00, 18.00, 24.00},
  {user4, 27.47, 41.205, 54.94},
  {user5, 12.00, 18.00, 24.00},
  {user6, 12.00, 18.00, 24.00},
  {user7, 12.00, 18.00, 24.00},
  {general_manager, 28.3, 42.45, 56.6}
]

for {user, hourly_rate, night_hourly_rate, additional_hourly_rate} <- users do
  TimeManagerApi.Repo.update!(
    TimeManagerApi.User.changeset(user, %{
      hourly_rate: hourly_rate,
      night_hourly_rate: night_hourly_rate,
      additional_hourly_rate: additional_hourly_rate
    })
  )
end

IO.puts("Seed data inserted successfully.")
