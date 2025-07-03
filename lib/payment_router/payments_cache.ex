defmodule PaymentRouter.PaymentsCache do
  require Logger
  use GenServer

  @table :payments_cache

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def get(uuid) do
    case :ets.lookup(@table, uuid) do
      [{^uuid, payment}] ->
        Logger.info("Cache HIT: #{@table}:#{uuid}")
        {:ok, payment}
      [] ->
        Logger.info("Cache MISS: #{@table}:#{uuid}")
        :not_found
    end
  end

  def put(uuid, payment) do
    :ets.insert(@table, {uuid, payment})
    Logger.info("Cache PUT: #{@table}:#{uuid}")
    :ok
  end

  # Server callbacks

  def init(_) do
    :ets.new(@table, [:named_table, :set, :public, read_concurrency: true])
    {:ok, %{}}
  end
end
