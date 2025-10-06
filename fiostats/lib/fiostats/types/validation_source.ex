defmodule Fiostats.Types.ValidationSource do
  use Ash.Type.Enum, values: [:human, :bank, :embedding, :llm]
end
