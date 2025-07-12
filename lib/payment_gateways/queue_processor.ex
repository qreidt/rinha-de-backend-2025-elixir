defmodule PaymentGateways.QueueProcessor do
  use GenServer

  @tick_interval 5000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_state) do
    setup_tick()

    {:ok, %{}}
  end

  defp setup_tick() do
    Process.send_after(self(), :tick, @tick_interval)
  end
end
