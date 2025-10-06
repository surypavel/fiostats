defmodule FiostatsWeb.Components.TableComponent do
  use Phoenix.Component

  attr :payments_count, :integer
  attr :payments, :list
  attr :options, :list

  def table(assigns) do
    ~H"""
    <table class="table table-fixed w-full table-responsive">
      <tr class="max-sm:hidden">
        <th class="text-slate-500 w-4"></th>
        <th class="text-slate-500 w-40">Type</th>
        <th class="text-slate-500 w-40">Amount</th>
        <th class="text-slate-500 w-28">Paid at</th>
        <th class="text-slate-500 w-full">Description</th>
      </tr>
      <%= for payment <- @payments do %>
        <tr id={"payment" <> payment.id}>
          <td class="px-0 text-center">
            <div class="max-sm:hidden">
              <%= case payment.validation_source do %>
                <% :human -> %>
                  <div class="tooltip tooltip-right	" data-tip="Matched manually">
                    <span class="badge badge-success badge-xs"></span>
                  </div>
                <% :llm -> %>
                  <div
                    class="tooltip tooltip-right	"
                    data-tip={"Matched with LLM: " <> payment.classification_reason}
                  >
                    <span class="badge badge-primary badge-xs"></span>
                  </div>
                <% :embedding -> %>
                  <div class="tooltip tooltip-right	" data-tip="Matched with embedding">
                    <span class="badge badge-secondary badge-xs"></span>
                  </div>
                <% :bank -> %>
                  <div class="tooltip tooltip-right	" data-tip="Matched with bank transaction">
                    <span class="badge badge-ghost badge-xs"></span>
                  </div>
                <% nil -> %>
              <% end %>
            </div>
          </td>

          <td class="py-0">
            <%= if not payment.has_embedding? or payment.classification == nil do %>
              <span class="loading loading-spinner loading-xs"></span>
            <% else %>
              <form phx-change="set_classification">
                <select
                  name="classification"
                  class={["w-full select rounded-full select-sm"]}
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
          <td>
            <strong class={[
              Decimal.compare(payment.amount, Decimal.new(0)) == :gt && "text-success",
              Decimal.compare(payment.amount, Decimal.new(0)) == :lt && "text-error"
            ]}>
              {payment.amount |> Decimal.round(0) |> Decimal.to_integer()} CZK
            </strong>
          </td>
          <td>{Calendar.strftime(payment.date, "%d. %m. %Y")}</td>
          <td>
            <div class="md:truncate text-slate-500">
              <%= if payment.account do %>
                <a class="text-primary" phx-click="filter" phx-value-account={payment.account}>{payment.account}</a>:
              <% end %>
              {payment.title}
            </div>
          </td>
        </tr>
      <% end %>
      <%= if @payments_count > 100 do %>
        <tr>
          <td colspan="5">
            And {@payments_count - 100} more...
          </td>
        </tr>
      <% end %>
    </table>
    """
  end
end
