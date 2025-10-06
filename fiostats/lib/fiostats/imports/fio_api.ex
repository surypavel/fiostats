defmodule Fiostats.Imports.FioApi do
  def get_token() do
    System.get_env("FIO_TOKEN")
  end

  def set_last_id(external_id) do
    url =
      "https://fioapi.fio.cz/v1/rest/set-last-id/" <>
        get_token() <> "/" <> Integer.to_string(external_id) <> "/"

    %{status_code: 200} = HTTPoison.get!(url)
  end

  def get_transactions_json() do
    url = "https://fioapi.fio.cz/v1/rest/last/" <> get_token() <> "/transactions.json"

    case HTTPoison.get!(url) do
      %{status_code: 200, body: body} -> {:ok, JSON.decode!(body)}
      %{status_code: status_code} -> {:error, {:http_error, status_code}}
    end
  end
end
