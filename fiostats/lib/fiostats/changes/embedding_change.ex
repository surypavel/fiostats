defmodule Fiostats.Changes.EmbeddingChange do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.before_action(changeset, fn changeset ->
      # Get the title from the changeset
      title = Ash.Changeset.get_attribute(changeset, :title)

      # Generate embedding text from title
      text = "Comment of the card transaction: #{title}"

      # Call Gemini API - if it fails, the error propagates and Oban will retry
      {:ok, [embedding]} = Fiostats.LLM.GeminiEmbedding.generate([text], %{})

      # Set the embedding on the changeset
      Ash.Changeset.force_change_attribute(changeset, :full_text_vector, embedding)
    end)
  end
end
