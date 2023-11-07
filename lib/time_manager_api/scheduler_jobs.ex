defmodule TimeManagerApi.SchedulerJobs do
  alias TimeManagerApi.Repo
  alias TimeManagerApi.User

  def increment_paid_leave_balance do
    Repo.transaction(fn ->
      Repo.all(User)
      |> Enum.each(fn user ->
        new_balance = user.paid_leave_balance + 0.08928571428571429

        user
        |> User.changeset(%{paid_leave_balance: new_balance})
        |> Repo.update!()
      end)
    end)
  end
end
