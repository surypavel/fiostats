defmodule FiostatsWeb.SettingsLive do
  use Phoenix.LiveView
  alias Fiostats.Transactions.TransactionTypes
  alias Fiostats.Transactions.Dashboards

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:classifications, TransactionTypes.get_options())
     |> assign(:dashboards, Dashboards.get_options())}
  end

  def render(assigns) do
    ~H"""
    <div class="navbar bg-base-100 shadow-md px-6 sm:px-8 space-x-2 justify-between">
      <div class="flex-1 lg:flex-0">
        <a class="text-xl whitespace-nowrap font-serif">Transactions</a>
      </div>

      <div class="flex flex-0 flex-row items-center space-x-4">
        <.link navigate="/">
          <button class="btn btn-soft btn-md flex-0 my-2">
            <FiostatsWeb.CoreComponents.icon name="hero-arrow-left" class="size-5" />
          </button>
        </.link>

        <div>
          <FiostatsWeb.Layouts.theme_toggle />
        </div>
      </div>
    </div>

    <div class="container mx-auto px-4 py-8 space-y-8">
      <h1 class="text-xl font-bold mb-6">Classifications</h1>
      <div class="space-y-4">
        <ul class="list bg-base-100 rounded-box shadow-md">
          <%= for classification <- @classifications |> Enum.sort_by(fn c -> c.llm_description == nil end) do %>
            <li class="list-row">
              <div class="flex flex-col">
                <span class="text-lg font-medium">{classification.name}</span>
                <p :if={classification.llm_description != nil} class="text-base-content/70">
                  {classification.llm_description}
                </p>
                <p :if={classification.llm_description == nil} class="text-warning">
                  Not used by LLM
                </p>
              </div>
            </li>
          <% end %>
        </ul>
      </div>

      <h1 class="text-xl font-bold mb-6">Dashboards</h1>
      <div class="space-y-4">
        <ul class="list bg-base-100 rounded-box shadow-md">
          <%= for dashboard <- @dashboards do %>
            <li class="list-row">
              <div class="flex flex-col">
                <span class="text-lg font-medium">{dashboard.name}</span>
                <div class="flex flex-wrap gap-2 mt-2">
                  <%= for column <- dashboard.columns do %>
                    <div class="tooltip tooltip-bottom" data-tip={column.expr}>
                      <div class="badge badge-sm" style={"background-color: #{column.color};"}></div>
                      <span class="text-sm text-base-content/70">{column.name}</span>
                    </div>
                  <% end %>
                </div>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end
end
