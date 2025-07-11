defmodule PaymentRouter.PaymentsCache do
  require Logger
  use GenServer

  alias PaymentRouter.Payments.AcceptedPayment

  @ttl_ms 10_000
  @cleanup_frequency_ms 60_000
  @table :payments_cache

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec get(any()) :: :not_found | {:ok, any()}
  def get(uuid) do
    case :ets.lookup(@table, uuid) do
      [{^uuid, payment, _}] ->
        Logger.info("Cache HIT: #{@table}:#{uuid}")
        {:ok, payment}
      [] ->
        Logger.info("Cache MISS: #{@table}:#{uuid}")
        :not_found
    end
  end

  @spec put(String.t(), %AcceptedPayment{}) :: :ok
  def put(uuid, %AcceptedPayment{} = payment) do
    :ets.insert(@table, {uuid, payment, now_ms()})
    Logger.info("Cache PUT: #{@table}:#{uuid}")
    :ok
  end

  # Server callbacks

  def init(_) do
    # Create ETS table
    :ets.new(@table, [:named_table, :set, :public, read_concurrency: true])

    # Start cleanup Routine
    schedule_cleanup()

    {:ok, %{}}
  end

  def handle_info(:cleanup, state) do
    Logger.info("Running cache table cleanup: #{@table}")

    cleanup_expired()
    schedule_cleanup()
    {:noreply, state}
  end

  # Helpers

  defp now_ms, do: System.system_time(:millisecond)

  defp cleanup_expired do
    now = now_ms()
    for {uuid, _payment, inserted_at} <- :ets.tab2list(@table),
        now - inserted_at >= @ttl_ms do

      Logger.info("Cache Key Expired: #{@table}:#{uuid}")
      :ets.delete(@table, uuid)
    end
  end

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, @cleanup_frequency_ms)
    nil
  end
end
