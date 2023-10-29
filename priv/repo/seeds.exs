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

# Previous users and teams
user1 = TimeManagerApi.Repo.insert!(%TimeManagerApi.User{username: "user1", email: "user1@example.com", role: :manager})
user2 = TimeManagerApi.Repo.insert!(%TimeManagerApi.User{username: "user2", email: "user2@example.com", role: :employee})
user3 = TimeManagerApi.Repo.insert!(%TimeManagerApi.User{username: "user3", email: "user3@example.com", role: :employee})
team1 = TimeManagerApi.Repo.insert!(%TimeManagerApi.Team{name: "Team1", manager_id: user1.id})
user1 = Ecto.Changeset.change(user1, team_id: team1.id) |> TimeManagerApi.Repo.update!()

# Additional team
team2 = TimeManagerApi.Repo.insert!(%TimeManagerApi.Team{name: "Team2"})

# New manager associated with team2
user4 = TimeManagerApi.Repo.insert!(%TimeManagerApi.User{username: "user4", email: "user4@example.com", role: :manager, team_id: team2.id})

# Update team2 to associate it with user4 as its manager
team2 = Ecto.Changeset.change(team2, manager_id: user4.id) |> TimeManagerApi.Repo.update!

# Two employees associated with team2
user5 = TimeManagerApi.Repo.insert!(%TimeManagerApi.User{username: "user5", email: "user5@example.com", role: :employee, team_id: team2.id})
user6 = TimeManagerApi.Repo.insert!(%TimeManagerApi.User{username: "user6", email: "user6@example.com", role: :employee, team_id: team2.id})

# Employee without any team
user7 = TimeManagerApi.Repo.insert!(%TimeManagerApi.User{username: "user7", email: "user7@example.com", role: :employee})

# General manager
general_manager = TimeManagerApi.Repo.insert!(%TimeManagerApi.User{username: "general_manager", email: "gm@example.com", role: :general_manager})

# working times
current_date = Date.utc_today()
days_until_monday = cond do
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
TimeManagerApi.Repo.insert!(%TimeManagerApi.Clock{status: false, time: NaiveDateTime.truncate(DateTime.to_naive(DateTime.utc_now()), :second), user_id: user1.id})
TimeManagerApi.Repo.insert!(%TimeManagerApi.Clock{status: true, time: NaiveDateTime.truncate(DateTime.to_naive(DateTime.utc_now()), :second), user_id: user2.id})
TimeManagerApi.Repo.insert!(%TimeManagerApi.Clock{status: false, time: NaiveDateTime.truncate(DateTime.to_naive(DateTime.utc_now()), :second), user_id: user3.id})

IO.puts("Seed data inserted successfully.")
