defmodule Fiostats.LLM.GeminiEmbedding do
  use AshAi.EmbeddingModel

  @api_key System.get_env("GEMINI_API_KEY")
  @model_url "https://generativelanguage.googleapis.com/v1beta/models/gemini-embedding-001:embedContent?key=#{@api_key}"

  @impl true
  def dimensions(_opts), do: 768

  @impl true
  def generate(texts, _opts) do
    body =
      Jason.encode!(%{
        content: %{
          parts:
            texts
            |> Enum.map(fn text ->
              %{
                text: text |> String.replace("Nákup: ", "")
              }
            end)
        },
        output_dimensionality: 768
      })

    headers = [
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.post(@model_url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        response = Jason.decode!(response_body)
        embedding = get_in(response, ["embedding", "values"])
        {:ok, [embedding]}

      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, "API error #{code}: #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
