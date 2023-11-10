defmodule TimeManagerApi.SchedulerJobs do
  alias TimeManagerApi.{Repo, User, WorkingTimes, Mailer}
  use Bamboo.Mailer, otp_app: :time_manager_api
  import Ecto.Query

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

  def send_email_to_all_users do
    User
    |> Repo.all()
    |> Enum.each(&send_email/1)
  end

  def send_email(user) do
    api_key = System.get_env("SENDGRID_API_KEY")
    email = user.email

    pdf_path = generate_payslip_pdf(user)

    {:ok, pdf_binary} = File.read(pdf_path)
    pdf_base64 = Base.encode64(pdf_binary)

    data =
      %{
        "personalizations" => [%{"to" => [%{"email" => email}]}],
        "from" => %{"email" => "bamibi1803@mkurg.com"},
        "subject" => "Votre Fiche de Paie",
        "content" => [
          %{"type" => "text/plain", "value" => "Veuillez trouver ci-joint votre fiche de paie."}
        ],
        "attachments" => [
          %{
            "content" => pdf_base64,
            "type" => "application/pdf",
            "filename" => "#{user.username}_payslip.pdf",
            "disposition" => "attachment"
          }
        ]
      }
      |> Jason.encode!()

    System.cmd("curl", [
      "--request",
      "POST",
      "--url",
      "https://api.sendgrid.com/v3/mail/send",
      "--header",
      "Authorization: Bearer #{api_key}",
      "--header",
      "Content-Type: application/json",
      "--data",
      data
    ])

    # File.rm(pdf_path)
  end

  # Generate PDF

  def generate_payslip_pdf(user) do
    content = payslip_content(user)

    root_dir = File.cwd!()

    payslips_dir = Path.join([root_dir, "lib", "time_manager_api", "mails", "payslips"])

    File.mkdir_p(payslips_dir)

    pdf_filename = "#{user.username}_payslip.pdf"
    output_path = Path.join([payslips_dir, pdf_filename])

    {:ok, temp_filename} = PdfGenerator.generate(content, page_size: "A4")

    File.rename(temp_filename, output_path)

    output_path
  end

  defp calculate_monthly_night_hours(user_id) do
    from(w in TimeManagerApi.Workingtimes,
      where: w.user_id == ^user_id,
      where: w.start >= ago(30, "day")
    )
    |> Repo.all()
    |> Enum.reduce(0, fn working_time, acc ->
      night_hours = working_time.night_hours_worked || 0
      acc + night_hours
    end)
  end

  defp calculate_monthly_hours(user_id) do
    from(w in TimeManagerApi.Workingtimes,
      where: w.user_id == ^user_id,
      where: w.start >= ago(30, "day")
    )
    |> Repo.all()
    |> Enum.reduce(0, fn working_time, acc ->
      hours_worked = working_time.hours_worked || 0
      acc + hours_worked
    end)
  end

  defp payslip_content(user) do
    datetime = Timex.now()
    current_date = Timex.format!(datetime, "{YYYY}-{0M}-{0D}")
    current_month = Timex.now() |> Timex.format!("{Mfull}")

    monthly_night_hours = calculate_monthly_night_hours(user.id)
    monthly_hours_worked = calculate_monthly_hours(user.id)

    gross_salary = Float.round(user.gross_hourly_rate * monthly_hours_worked, 2)

    night_salary = Float.round(user.night_hourly_rate * monthly_night_hours, 2)
    salary = Float.round(user.hourly_rate * monthly_hours_worked, 2)

    """
    <html>
      <head>
        <title>Fiche de Paie</title>
        <style>
        body {
          font-family: Arial, sans-serif;
          color: #333;
          padding: 20px;
      }

      #payslip {
          border: 1px solid #ccc;
          padding: 10px;
          margin-bottom: 50px;
      }

      #title {
          font-size: 24px;
          font-weight: bold;
          text-align: center;
          margin-bottom: 20px;
      }

      #scope {
          display: flex;
          justify-content: space-between;
          margin-bottom: 20px;
      }

      .scope-entry {
          width: 45%;
      }

      .scope-entry .title {
          font-weight: bold;
      }

      .clear {
        clear: both;
        display: table;
        content: "";
      }

      .content:before {
        content: "";
        display: block;
        height: 20px;
    }

      .content {
          display: flex;
          justify-content: space-between;
          padding-top: 20px;
      }

      .left-panel {
        float: left;
        width: 45%;
    }

    .right-panel {
        float: right;
        width: 45%;
    }

    .left-panel, .right-panel {
      margin-top: 20px;
    }

      #employee {
          margin-bottom: 20px;
      }

      #employee #name {
          font-size: 20px;
          font-weight: bold;
      }

      .details .entry {
          display: flex;
          justify-content: space-between;
          margin-bottom: 10px;
      }

      .details .entry .label {
          font-weight: bold;
      }

      .details .entry .value {
          text-align: right;
      }

      .basic-pay, .salary, .leaves, .taxable_allowance, .taxable_bonus, .net_pay {
          border: 1px solid #ccc;
          padding: 10px;
          margin-bottom: 20px;
      }

      .basic-pay .entry, .salary .entry, .leaves .entry, .taxable_allowance .entry, .taxable_bonus .entry, .net_pay .entry {
          margin-bottom: 10px;
      }

      .basic-pay .entry .label, .salary .entry .label, .leaves .entry .label, .taxable_allowance .entry .label, .taxable_bonus .entry .label, .net_pay .entry .label {
          font-weight: bold;
      }

      .basic-pay .entry .amount, .salary .entry .amount, .leaves .entry .amount, .taxable_allowance .entry .amount, .taxable_bonus .entry .amount, .net_pay .entry .amount {
          text-align: right;
          font-weight: bold;
      }
        </style>
      </head>
      <body>
      <div id="payslip">
      <div id="title">Payslip</div>
      <div id="scope">
        <div class="scope-entry">
          <div class="title">PAY RUN</div>
          <div class="value">#{current_month}</div>
        </div>
        <div class="scope-entry">
          <div class="title">PAY PERIOD</div>
          <div class="value">#{current_date}</div>
        </div>
      </div>
      <div class="content">
        <div class="left-panel">
          <div id="employee">
            <div id="name">
            #{String.upcase(user.lastname)} #{String.capitalize(user.firstname)}
          </div>
            <div id="email">
              #{user.email}
            </div>
          </div>
          <div class="details">
            <div class="entry">
              <div class="label">Employee ID</div>
              <div class="value">#{user.id}</div>
            </div>
            <div class="entry">
              <div class="label">Tax Status</div>
              <div class="value">Married - 2 Dependents</div>
            </div>
            <div class="entry">
              <div class="label">Hourly Rate</div>
              <div class="value">#{user.hourly_rate}</div>
            </div>
            <div class="entry">
              <div class="label">Company Name</div>
              <div class="value">EpicHourly</div>
            </div>
            <div class="entry">
              <div class="label">Payroll Cycle</div>
              <div class="value">Monthly</div>
            </div>
            <div class="entry">
              <div class="label">Prepared by</div>
              <div class="value">Marc-Aurele Lavalle</div>
            </div>
          </div>
          <div class="ytd">
          </div>
        </div>
        <div class="right-panel">
          <div class="details">
            <div class="basic-pay">
              <div class="entry">
                <div class="label">Basic Pay</div>
                <div class="detail"></div>

                <div class="amount">#{gross_salary}</div>
              </div>
            </div>
            <div class="salary">
              <div class="entry">
                <div class="label">Salary</div>
                <div class="detail"></div>
                <div class="rate"></div>
                <div class="amount"></div>
              </div>
              <div class="entry">

                <div class="detail">Overtime</div>

                <div class="amount">00.00</div>
              </div>
              <div class="entry">

                <div class="detail">Unworked Holiday</div>

                <div class="amount">00.00</div>
              </div>
              <div class="entry">

                <div class="detail">Regular Holiday</div>

                <div class="amount">00.00</div>
              </div>
              <div class="entry">
                <div class="amount">00.00</div>
              </div>
              <div class="entry">

                <div class="detail">Night</div>

                <div class="amount">#{night_salary}</div>
              </div>
              <div class="entry">
                <div class="amount">00.00</div>
              </div>
              <div class="entry">
                <div class="detail">Regular Holiday Night</div>
                <div class="amount">00.00</div>
              </div>
              <div class="entry">

                <div class="detail">Regular Holiday Night Overtime</div>

                <div class="amount">00.00</div>
              </div>
            </div>
            <div class="leaves">
              <div class="entry">
                <div class="label">Leaves</div>
                <div class="detail"></div>

                <div class="amount"></div>
              </div>
              <div class="entry paid">

                <div class="detail">Remaining Paid Leave</div>

                <div class="amount">#{Float.round(user.paid_leave_balance, 3)}</div>
              </div>
              <div class="entry unpaid">

                <div class="detail">Paid Leave</div>

                <div class="amount">00.00</div>
              </div>
            </div>
            <div class="taxable_allowance">
              <div class="entry">
                <div class="label">Taxable Allowance</div>
                <div class="detail"></div>

                <div class="amount"></div>
              </div>
              <div class="entry">

                <div class="detail">Allowance Name</div>

                <div class="amount"00.00</div>
              </div>
            </div>

            <div class="net_pay">
              <div class="entry">
                <div class="label">NET PAY</div>
                <div class="detail"></div>
                <div class="rate"></div>
                <div class="amount">#{salary}</div>
              </div>
          </div>
        </div>
      </div>
    </div>
    </body>
    </html>
    """
  end
end
