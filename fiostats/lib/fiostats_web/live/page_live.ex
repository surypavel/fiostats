defmodule FiostatsWeb.PageLive do
  require Ash.Query
  require Ash.Sort
  require Ecto.Query
  alias Fiostats.Imports
  use Phoenix.LiveView

  def assign_transactions(socket) do
    filter = socket.assigns.filter
    data = Fiostats.Aggregations.Transactions.get_data(filter)

    socket
    |> assign(:payments, data.payments)
    |> assign(:payments_count, data.payments_count)
    |> assign(:graph_data, data.graph_data)
    |> send_update_data()
  end

  def mount(_conn, _params, socket) do
    if connected?(socket) do
      FiostatsWeb.Endpoint.subscribe("transactions")
    end

    {:ok,
     socket
     |> assign(:options, Fiostats.Transactions.TransactionTypes.get_options())
     |> assign(:filter, %{
       classification: "",
       search: "",
       account: "",
       date_from: "",
       date_to: "",
       is_fuzzy: false
     })
     |> assign(:dashboard, "spending")
     |> assign(:period, "year")}
  end

  def handle_params(params, _uri, socket) do
    socket =
      case Jason.decode(params["filter"] || "{}") do
        {:ok, filter} ->
          socket
          |> assign(:filter, %{
            classification: (filter && filter["classification"]) || "",
            search: (filter && filter["search"]) || "",
            account: (filter && filter["account"]) || "",
            date_from: (filter && filter["date_from"]) || "",
            date_to: (filter && filter["date_to"]) || "",
            is_fuzzy: (filter && filter["is_fuzzy"]) || false
          })

        _ ->
          socket
      end

    socket =
      case params["dashboard"] do
        nil -> socket
        _ -> socket |> assign(:dashboard, params["dashboard"])
      end

    socket =
      case params["period"] do
        nil -> socket
        _ -> socket |> assign(:period, params["period"])
      end

    {:noreply, socket |> assign_transactions()}
  end

  def render(assigns) do
    ~H"""
    <div class="navbar bg-base-100 shadow-md px-6 sm:px-8 space-x-2 justify-between">
      <div class="flex-1 lg:flex-0">
        <a class="text-xl whitespace-nowrap font-serif">Transactions</a>
      </div>

      <div class="flex flex-0 flex-row items-center space-x-4">
        <div class="flex flex-0 flex-end space-x-2 flex-row">
          <.link navigate="/settings">
            <button class="btn btn-soft btn-md flex-0 my-2">
              <FiostatsWeb.CoreComponents.icon name="hero-cog-6-tooth" class="size-5" />
            </button>
          </.link>

          <button class="btn btn-primary btn-md flex-0 my-2" phx-click="update">
            Update
          </button>
        </div>
      </div>
    </div>

    <div class="px-2 py-2 sm:px-4 sm:py-4 lg:px-8 lg:py-8">
      <div class="mx-auto lg:mx-0">
        <div class="md:space-y-6 space-y-2">
          <FiostatsWeb.Components.FilterComponent.filter options={@options} filter={@filter} />

          <%= if @payments_count > 0 do %>
            <div class="card bg-base-100 w-full">
              <div class="card-body">
                <h2 class="card-title">Dashboards</h2>

                <div role="tablist" class="tabs tabs-border pb-0">
                  <%= for dashboard <- Fiostats.Transactions.Dashboards.get_options() do %>
                    <.link
                      role="tab"
                      class={["tab", @dashboard == dashboard.id && "tab-active"]}
                      patch={
                        "/?dashboard=#{dashboard.id}&period=#{@period}&filter=#{Jason.encode!(@filter)}"
                      }
                    >
                      {dashboard.name}
                    </.link>
                  <% end %>
                </div>

                <div
                  id="bar-chart-2"
                  phx-hook="BarChart"
                  phx-update="ignore"
                  data-chart-data={
                    Jason.encode!(
                      Fiostats.Aggregations.Chart.make(
                        @dashboard,
                        @graph_data,
                        @period
                      )
                    )
                  }
                />
              </div>

              <div class="card-actions justify-end">
                <div role="tablist" class="tabs">
                  <%= for period <- Fiostats.Aggregations.TimeUtils.get_granularities() do %>
                    <.link
                      role="tab"
                      class={["tab", @period == period && "tab-active"]}
                      patch={
                        "/?dashboard=#{@dashboard}&period=#{period}&filter=#{Jason.encode!(@filter)}"
                      }
                    >
                      {period}
                    </.link>
                  <% end %>
                </div>
              </div>
            </div>
          <% end %>

          <div class="card bg-base-100 w-full">
            <div class="card-body">
              <h2 class="card-title">Transactions</h2>

              <FiostatsWeb.Components.TableComponent.table
                options={@options}
                payments={@payments |> Enum.slice(0, 100)}
                payments_count={@payments_count}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp maybe_update(filter, _key, nil), do: filter
  defp maybe_update(filter, key, value), do: Map.put(filter, key, value)

  def handle_event("filter", params, socket) do
    current_filter = socket.assigns.filter

    updated_filter =
      current_filter
      |> maybe_update(:classification, params["classification"])
      |> maybe_update(:search, params["search"])
      |> maybe_update(:date_from, params["date_from"])
      |> maybe_update(:date_to, params["date_to"])
      |> maybe_update(
        :is_fuzzy,
        if params["is_fuzzy"] != nil or params["_target"] == ["is_fuzzy"] do
          params["is_fuzzy"] == "on"
        else
          nil
        end
      )
      |> maybe_update(:account, params["account"])

    {:noreply,
     socket
     |> push_patch(
       to:
         "/?dashboard=#{socket.assigns.dashboard}&period=#{socket.assigns.period}&filter=#{Jason.encode!(updated_filter)}"
     )}
  end

  def handle_event("update", _, socket) do
    case Imports.read_from_fio() do
      {:ok, new_payments} ->
        case Imports.insert_to_db(new_payments) do
          %{status: :success} ->
            {:noreply, socket |> put_flash(:info, "New payments were loaded successfully.")}

          _ ->
            {:noreply, socket |> put_flash(:error, "Unable to save new payments.")}
        end

      {:error, {:http_error, 409}} ->
        {:noreply, socket |> put_flash(:error, "Unable to load new payments from the API.")}
    end
  end

  def handle_event(
        "set_classification",
        %{"classification" => classification, "payment_id" => id},
        socket
      ) do
    {:ok, transaction} = Fiostats.Transactions.Transaction |> Ash.get(id)

    {:ok, _} =
      transaction
      |> Ash.Changeset.for_update(:manually_set_classification, %{classification: classification})
      |> Ash.update()

    {:noreply, socket |> put_flash(:info, "Classification updated")}
  end

  def handle_info(%Phoenix.Socket.Broadcast{topic: "transactions"}, socket) do
    {:noreply, socket |> assign_transactions()}
  end

  def send_update_data(socket) do
    data =
      Fiostats.Aggregations.Chart.make(
        socket.assigns.dashboard,
        socket.assigns.graph_data,
        socket.assigns.period
      )

    socket
    |> push_event("update_chart", %{
      data: data
    })
  end
end
