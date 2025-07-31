defmodule PaymentGateways.Resolver do
  require Logger
  use GenServer

  @main_table :gateway_resolver
  @health_check_interval 5000

  def hosts do
    Application.get_env(:payment_router, PaymentGateways.Resolver)[:hosts]
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_state) do
    Logger.info("[PaymentGateways.Resolver] starting.")

    create_ets_tables()
    schedule_health_check()

    Logger.info("[PaymentGateways.Resolver] started.")

    {:ok, %{}}
  end

  @impl true
  def handle_info(:health_check, state) do
    schedule_health_check()
    check_health()
    {:noreply, state}
  end

  defp create_ets_tables() do
    # Create ETS table for storing the current gateway
    :ets.new(@main_table, [
      :named_table,
      :set,
      :public,
      read_concurrency: true,
      write_concurrency: true
    ])

    # Store the initial gateway (default to the first one)
    gateway = get_prefered_gateway()

    :ets.insert(@main_table, {:current_gateway, gateway})

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
    prefered_gateway = get_prefered_gateway()
    set_current_gateway(prefered_gateway)
  end

  defp get_prefered_gateway() do
    filtered_gateways =
      hosts()
      |> run_async_task()
      |> Enum.filter(fn {_id, _url, failing?, _response_time} -> !failing? end)

    if Enum.count(filtered_gateways) == 0, do: nil, else: List.first(filtered_gateways)
  end

  defp run_async_task(hosts) do
    hosts
    |> Enum.map(fn host -> Task.async(fn -> handle_async_task(host) end) end)
    |> Task.await_many()
    |> Enum.filter(fn v -> v != :error end)
  end

  defp handle_async_task({id, base_url}) do
    with {:ok, failing?, min_response_time} <- PaymentGateway.Client.service_health(base_url) do
      Logger.info("[PaymentGateways.Resolver][#{base_url}][#{failing?}][#{min_response_time} ms]")
      if failing? or min_response_time > 0 do
        Logger.warning("[PaymentGateways.Resolver][#{base_url}][#{failing?}][#{min_response_time} ms]")
      end
      {id, base_url, failing?, min_response_time}
    end
  end
end
