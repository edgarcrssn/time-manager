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

# users
user1 = TimeManagerApi.Repo.insert!(%TimeManagerApi.User{username: "user1", email: "user1@example.com"})
user2 = TimeManagerApi.Repo.insert!(%TimeManagerApi.User{username: "user2", email: "user2@example.com"})
user3 = TimeManagerApi.Repo.insert!(%TimeManagerApi.User{username: "user3", email: "user3@example.com"})

# working times
start1 = DateTime.truncate(DateTime.utc_now(), :second)
end1 = DateTime.truncate(DateTime.add(start1, 1, :second), :second)
TimeManagerApi.Repo.insert!(%TimeManagerApi.Workingtimes{start: start1, end: end1, user_id: user1.id})

start2 = DateTime.truncate(DateTime.utc_now(), :second)
end2 = DateTime.truncate(DateTime.add(start2, 2, :second), :second)
TimeManagerApi.Repo.insert!(%TimeManagerApi.Workingtimes{start: start2, end: end2, user_id: user2.id})

start3 = DateTime.truncate(DateTime.utc_now(), :second)
end3 = DateTime.truncate(DateTime.add(start3, 3, :second), :second)
TimeManagerApi.Repo.insert!(%TimeManagerApi.Workingtimes{start: start3, end: end3, user_id: user3.id})

# clocks
TimeManagerApi.Repo.insert!(%TimeManagerApi.Clock{status: false, time: NaiveDateTime.truncate(DateTime.to_naive(DateTime.utc_now()), :second), user_id: user1.id})
TimeManagerApi.Repo.insert!(%TimeManagerApi.Clock{status: true, time: NaiveDateTime.truncate(DateTime.to_naive(DateTime.utc_now()), :second), user_id: user2.id})
TimeManagerApi.Repo.insert!(%TimeManagerApi.Clock{status: false, time: NaiveDateTime.truncate(DateTime.to_naive(DateTime.utc_now()), :second), user_id: user3.id})

IO.puts("Seed data inserted successfully.")
