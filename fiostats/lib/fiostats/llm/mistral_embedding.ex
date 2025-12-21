defmodule Fiostats.LLM.MistralEmbedding do
  @api_key System.get_env("MISTRAL_API_KEY")
  @model_url "https://api.mistral.ai/v1/embeddings"

  def dimensions(_opts), do: 1024

  def generate(texts, _opts) do
    headers = [
      {"Authorization", "Bearer #{@api_key}"},
      {"Content-Type", "application/json"}
    ]

    body = %{
      "input" => texts,
      "model" => "mistral-embed"
    }

    response =
      Req.post!(@model_url,
        json: body,
        headers: headers
      )

    case response.status do
      200 ->
        response.body["data"]
        |> Enum.map(fn %{"embedding" => embedding} -> embedding end)
        |> then(&{:ok, &1})

      _status ->
        {:error, response.body}
    end
  end
end
