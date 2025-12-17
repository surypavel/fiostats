alias LangChain.Chains.LLMChain
alias LangChain.Message

defmodule Fiostats.LLM.GeminiCompletion do
  alias LangChain.ChatModels.ChatGoogleAI

  def generate(text) do
    api_key = System.fetch_env!("GEMINI_API_KEY")

    # It seems to struggle with ci strings with utf chars
    text = text |> Ash.CiString.value()

    accepted_values =
      Fiostats.Transactions.TransactionTypes.get_options()
      |> Enum.filter(fn t -> t.llm_description != nil end)
      |> Enum.map(fn t -> t.id <> " (" <> t.llm_description <> ")\n" end)

    llm_response =
      %{llm: ChatGoogleAI.new!(%{model: "gemini-2.5-flash", api_key: api_key})}
      |> LLMChain.new!()
      |> LLMChain.add_messages([
        Message.new_system!(
          "You are an assistant that receives transactions notes from credit card payments and tries its best to guess the nature of the payment. Make sure to focus on details and not to just group everything as as purchase. This is the list of accepted values, with their explainations in the brackets: " <>
            (accepted_values |> Enum.join(", ")) <>
            ". Reply with an accepted value, a new line, and then with an explaination of your reasoning."
        ),
        Message.new_user!("Classify transaction: " <> text)
      ])
      |> LLMChain.run()
      |> IO.inspect()

    with {:ok, %{last_message: %{content: [%{content: content}]}}} <- llm_response do
      [classification | reasoning] = content |> String.split("\n")
      {:ok, classification, reasoning |> Enum.join("\n")}
    end
  end
end
