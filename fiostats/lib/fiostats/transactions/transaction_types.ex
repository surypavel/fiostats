defmodule Fiostats.Transactions.TransactionTypes do
  @options [
    %{id: "travel_costs", name: "Travel costs", llm_description: "booking hotels, plane tickets"},
    %{id: "earnings", name: "Earnings", llm_description: nil},
    %{id: "rent_and_apartment_received", name: "Rent (incoming)", llm_description: nil},
    %{
      id: "rent_and_apartment",
      name: "Rent (outgoing)",
      llm_description: "rent, PRE electricity, PPAS gas, t-mobile internet, radio and TV fees"
    },
    %{
      id: "bars_and_restaurants",
      name: "Eating out",
      llm_description: "bills from places serving food and drinks"
    },
    %{
      id: "groceries",
      name: "Groceries",
      llm_description: "bills from supermarkets and food shops"
    },
    %{
      id: "goods_and_purchases",
      name: "Purchases",
      llm_description: "clothing, electronics, sport equipment, cooking equipment etc"
    },
    %{
      id: "concerts_and_events",
      name: "Events",
      llm_description: "movie theatres, concerts, entry fees"
    },
    %{
      id: "means_of_transport",
      name: "Transport",
      llm_description: "public transport passes, train tickets, bus tickets"
    },
    %{id: "atm_withdrawal", name: "ATM withdrawal", llm_description: "for cash withdrawals"},
    %{
      id: "revolut",
      name: "Revolut",
      llm_description: "card payments to revolut, usually for paying in foreign currencies"
    },
    %{
      id: "taxes",
      name: "Taxes",
      llm_description: "taxes, payments for social security - ČSSZ, and for medical insurance"
    },
    %{id: "other", name: "Other", llm_description: "when it does not fit any of the categories"},
    %{id: "unclassified", name: "Unclassified", llm_description: nil},
    %{id: "ignored", name: "Ignored", llm_description: nil}
  ]

  def get_options() do
    @options
  end
end
