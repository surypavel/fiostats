defmodule FiostatsWeb.Components.FilterComponent do
  use Phoenix.Component

  attr :options, :list
  attr :filter, :map

  def filter(assigns) do
    ~H"""
    <form
      phx-change="filter"
      class="grid sm:grid-cols-3 md:grid-cols-6 gap-1 sm:gap-4 w-full max-w-full px-4"
    >
      <fieldset class="fieldset col-span-1">
        <legend class="fieldset-legend w-full">
          <span class="text-sm py-0.5">
            Type
          </span>
          <button
            :if={@filter.classification != ""}
            class="btn btn-ghost btn-xs"
            type="button"
            phx-click="filter"
            phx-value-classification=""
          >
            Clear
          </button>
        </legend>

        <select name="classification" class={["w-full select rounded-full"]}>
          <option value="">Any</option>
          {Phoenix.HTML.Form.options_for_select(
            @options |> Map.new(fn option -> {option.name, option.id} end),
            @filter.classification
          )}
        </select>
      </fieldset>

      <fieldset class="fieldset sm:col-span-2">
        <legend class="fieldset-legend w-full">
          <span class="text-sm py-0.5">
            Description
          </span>
          <button
            :if={@filter.search != ""}
            class="btn btn-ghost btn-xs"
            type="button"
            phx-click="filter"
            phx-value-search=""
            phx-value-is_fuzzy=""
          >
            Clear
          </button>
        </legend>
        <div class="flex flex-row items-center space-x-2">
          <label class="input rounded-full join-item flex-1">
            <svg class="h-[1em] opacity-50" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
              <g
                stroke-linejoin="round"
                stroke-linecap="round"
                stroke-width="2.5"
                fill="none"
                stroke="currentColor"
              >
                <circle cx="11" cy="11" r="8"></circle>
                <path d="m21 21-4.3-4.3"></path>
              </g>
            </svg>
            <input
              name="search"
              type="search"
              placeholder="Search"
              value={@filter.search}
              phx-debounce="500"
            />
          </label>
          <div class="tooltip tooltip-left" data-tip="Semantic search">
            <input
              type="checkbox"
              checked={@filter.is_fuzzy}
              class="toggle"
              name="is_fuzzy"
              value="on"
            />
          </div>
        </div>
      </fieldset>

      <fieldset class="fieldset col-span-1">
        <legend class="fieldset-legend w-full">
          <span class="text-sm py-0.5">
            Account number
          </span>
          <button
            :if={@filter.account != ""}
            class="btn btn-ghost btn-xs"
            type="button"
            phx-click="filter"
            phx-value-account=""
          >
            Clear
          </button>
        </legend>
        <label class="input rounded-full w-full">
          <input
            name="account"
            type="search"
            placeholder="Account number"
            value={@filter.account}
            phx-debounce="500"
          />
        </label>
      </fieldset>

      <fieldset class="flex-0 fieldset sm:col-span-2 w-full">
        <legend class="fieldset-legend w-full">
          <span class="text-sm py-0.5">
            Date from/to
          </span>
          <button
            :if={@filter.date_from != "" || @filter.date_to != ""}
            class="btn btn-ghost btn-xs"
            type="button"
            phx-click="filter"
            phx-value-date_from=""
            phx-value-date_to=""
          >
            Clear
          </button>
        </legend>
        <label class="input rounded-full join-item w-full">
          <input name="date_from" type="date" placeholder="From" value={@filter.date_from} />
          <input name="date_to" type="date" placeholder="To" value={@filter.date_to} />
        </label>
      </fieldset>
    </form>
    """
  end
end
