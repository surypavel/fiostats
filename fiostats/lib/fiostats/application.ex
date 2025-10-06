defmodule Fiostats.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FiostatsWeb.Telemetry,
      Fiostats.Repo,
      {DNSCluster, query: Application.get_env(:fiostats, :dns_cluster_query) || :ignore},
      {Oban,
       AshOban.config(
         Application.fetch_env!(:fiostats, :ash_domains),
         Application.fetch_env!(:fiostats, Oban)
       )},
      # Start a worker by calling: Fiostats.Worker.start_link(arg)
      # {Fiostats.Worker, arg},
      # Start to serve requests, typically the last entry
      {Phoenix.PubSub, name: Fiostats.PubSub},
      FiostatsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fiostats.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FiostatsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
