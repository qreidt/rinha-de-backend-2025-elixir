defmodule PaymentRouter.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PaymentRouterWeb.Telemetry,
      PaymentRouter.Repo,
      {DNSCluster, query: Application.get_env(:payment_router, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PaymentRouter.PubSub},
      # Start a worker by calling: PaymentRouter.Worker.start_link(arg)
      # {PaymentRouter.Worker, arg},
      # Start to serve requests, typically the last entry
      PaymentRouterWeb.Endpoint,
      PaymentRouter.PaymentsCache,
      PaymentGateways.Resolver,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PaymentRouter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PaymentRouterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
