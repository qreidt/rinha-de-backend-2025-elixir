defmodule PaymentGateways.Resolver do
  use GenServer

  @main_table :gateway_resolver
  @health_check_interval :timer.seconds(1)

  @hosts [
    {:gateway_a, "http://127.0.0.1:8000", 1.0},
    {:gateway_b, "http://127.0.0.1:8001", 2.0},
  ]


  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_state) do
    create_ets_tables()
    schedule_health_check()

    {:ok, %{}}
  end

  @impl true
  def handle_info(:health_check, state) do
    check_health()
    schedule_health_check()
    {:noreply, state}
  end

  defp create_ets_tables() do
    # Create ETS table for storing the current gateway
    :ets.new(@main_table, [:named_table, :set, :public, read_concurrency: true, write_concurrency: true])

    # Store the initial gateway (default to the first one)
    [{gateway, url, _weight} | _] = @hosts

    :ets.insert(@main_table, {:current_gateway, {gateway, url}})

    :ok
  end

  @doc """
  Returns the current gateway to be used for routing payments.
  """
  def current_gateway do
    case :ets.lookup(@main_table, :current_gateway) do
      [{:current_gateway, gateway}] -> gateway
      _ -> nil
    end
  end

  @doc """
  Sets the current gateway to be used for routing payments.
  """
  def set_current_gateway(gateway) do
    :ets.insert(@main_table, {:current_gateway, gateway})
    :ok
  end

  defp schedule_health_check do
    Process.send_after(self(), :health_check, @health_check_interval)
  end

  defp check_health() do
    [gateway | _] = @hosts
    {id, base_url, _weight} = gateway
    PaymentGateway.Client.service_health(base_url)
  end
end
