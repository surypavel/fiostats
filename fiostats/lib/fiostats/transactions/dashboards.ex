defmodule Fiostats.Transactions.Dashboards do
  @options [
    %{
      id: "spending",
      name: "Spending",
      columns: [
        # Blue Violet
        %{name: "Rent", expr: "rent_and_apartment/3.0", color: "#8A2BE2"},
        # Tomato
        %{name: "Eating out", expr: "bars_and_restaurants", color: "#FF6347"},
        # Light Sea Green
        %{name: "Transport", expr: "means_of_transport", color: "#20B2AA"},
        # Lime Green
        %{name: "Groceries", expr: "groceries", color: "#32CD32"},
        # Hot Pink
        %{name: "Events", expr: "concerts_and_events", color: "#FF69B4"},
        # Dodger Blue
        %{name: "Travel", expr: "travel_costs+revolut", color: "#1E90FF"},
        # Gold
        %{name: "Goods and purchases", expr: "goods_and_purchases", color: "#FFD700"},
        # Dark Gray
        %{name: "ATM withdrawal", expr: "atm_withdrawal", color: "#A9A9A9"},
        # Light Gray
        %{name: "Other", expr: "other", color: "#D3D3D3"}
      ]
    },
    %{
      id: "rent",
      name: "Rent",
      columns: [
        %{name: "Rent", expr: "rent_and_apartment", color: "#8A2BE2"}
      ]
    },
    %{
      id: "rent_incoming",
      name: "Incoming rent",
      columns: [
        %{
          name: "Standa & Emil",
          expr: "-rent_and_apartment_received",
          color: "#20825A"
        }
      ]
    },
    %{
      id: "invoices",
      name: "Invoices",
      columns: [
        %{name: "Invoices", expr: "-earnings", color: "#20B2AA"}
      ]
    },
    %{
      id: "savings",
      name: "Savings",
      columns: [
        %{
          name: "Savings",
          expr:
            "-earnings-taxes-rent_and_apartment/3.0-bars_and_restaurants-means_of_transport-groceries-concerts_and_events-travel_costs-revolut-goods_and_purchases-atm_withdrawal-other",
          color: "#D0B22A"
        }
      ]
    },
    %{
      id: "taxes",
      name: "Taxes",
      columns: [
        %{
          name: "Taxes",
          expr: "taxes",
          color: "#D0222A"
        }
      ]
    }
  ]

  def get_options() do
    @options
  end
end
