defmodule TimeManagerApiWeb.WorkingtimesService do
  @date_regex ~r/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+\-]\d{2}:\d{2}$/

  defp validate_date(datetime_string) do
    case Regex.match?(@date_regex, datetime_string) do
      true -> {:ok, datetime_string}
      false -> {:error, "The format is not valid"}
    end
  end

  def validate_format(datetime_string) do
    case validate_date(datetime_string) do
      {:ok, _} -> true
      _ -> false
    end
  end
end
