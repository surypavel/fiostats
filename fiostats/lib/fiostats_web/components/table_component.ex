defmodule FiostatsWeb.Components.TableComponent do
  use Phoenix.Component

  attr :payments, :list, required: true
  attr :options, :list
  attr :id, :string, required: true
  attr :total, :any, required: true

  def table(assigns) do
    ~H"""
    <div class="md:hidden px-1 py-2 font-semibold text-slate-500 border-b border-slate-200">
      Total:
      <strong class={[
        Decimal.compare(@total, Decimal.new(0)) == :gt && "text-success",
        Decimal.compare(@total, Decimal.new(0)) == :lt && "text-error"
      ]}>
        {@total |> Decimal.round(0) |> Decimal.to_integer()} CZK
      </strong>
    </div>
    <table class="table table-fixed w-full">
      <thead>
        <tr class="max-md:hidden">
          <th class="text-slate-500 w-4"></th>
          <th class="text-slate-500 w-40">Type</th>
          <th class="text-slate-500 w-40">Amount</th>
          <th class="text-slate-500 w-28">Paid at</th>
          <th class="text-slate-500">Description</th>
        </tr>
        <tr class="border-b border-slate-200 max-md:hidden">
          <th></th>
          <th class="text-slate-500 font-semibold">Total</th>
          <th>
            <strong class={[
              Decimal.compare(@total, Decimal.new(0)) == :gt && "text-success",
              Decimal.compare(@total, Decimal.new(0)) == :lt && "text-error"
            ]}>
              {@total |> Decimal.round(0) |> Decimal.to_integer()} CZK
            </strong>
          </th>
          <th></th>
          <th></th>
        </tr>
      </thead>
      <tbody id={@id} phx-update="stream">
        <%= for {dom_id, payment} <- @payments do %>
          <tr
            id={dom_id}
            class="max-md:flex max-md:items-center max-md:gap-2 max-md:py-2 max-md:border-b max-md:border-slate-100"
          >
            <td class="px-0 text-center max-md:hidden">
              <%= case payment.validation_source do %>
                <% :human -> %>
                  <div class="tooltip tooltip-right" data-tip="Matched manually">
                    <span class="badge badge-success badge-xs"></span>
                  </div>
                <% :llm -> %>
                  <div
                    class="tooltip tooltip-right"
                    data-tip={"Matched with LLM: " <> payment.classification_reason}
                  >
                    <span class="badge badge-primary badge-xs"></span>
                  </div>
                <% :embedding -> %>
                  <div class="tooltip tooltip-right" data-tip="Matched with embedding">
                    <span class="badge badge-secondary badge-xs"></span>
                  </div>
                <% :bank -> %>
                  <div class="tooltip tooltip-right" data-tip="Matched with bank transaction">
                    <span class="badge badge-ghost badge-xs"></span>
                  </div>
                <% nil -> %>
              <% end %>
            </td>

            <td class="py-0 max-md:p-0 max-md:shrink-0 max-md:w-28">
              <%= if not payment.has_embedding? or payment.classification == nil do %>
                <span class="loading loading-spinner loading-xs"></span>
              <% else %>
                <form phx-change="set_classification">
                  <select
                    name="classification"
                    class="w-full select rounded-full select-sm max-md:select-xs"
                    phx-value-id={payment.id}
                  >
                    <option value="">Any</option>
                    {Phoenix.HTML.Form.options_for_select(
                      @options |> Map.new(fn option -> {option.name, option.id} end),
                      payment.classification || "unclassified"
                    )}
                  </select>
                  <input type="hidden" name="payment_id" value={payment.id} />
                </form>
              <% end %>
            </td>

            <td class="whitespace-nowrap max-md:p-0 max-md:shrink-0">
              <strong class={[
                Decimal.compare(payment.amount, Decimal.new(0)) == :gt && "text-success",
                Decimal.compare(payment.amount, Decimal.new(0)) == :lt && "text-error"
              ]}>
                {payment.amount |> Decimal.round(0) |> Decimal.to_integer()} CZK
                <%= if Decimal.compare(payment.share, Decimal.new(1)) != :eq do %>
                  <sup class="text-slate-400 font-normal">1/{payment.share |> Decimal.round(0) |> Decimal.to_integer()}</sup>
                <% end %>
              </strong>
            </td>

            <td class="max-md:hidden">{Calendar.strftime(payment.date, "%d. %m. %Y")}</td>

            <td class="max-md:p-0 max-md:flex-1 max-md:min-w-0">
              <div class="truncate text-slate-500 max-md:text-xs">
                <%= if payment.account do %>
                  <a class="text-primary" phx-click="filter" phx-value-account={payment.account}>{payment.account}</a>:
                <% end %>
                {payment.title}
              </div>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end
end
