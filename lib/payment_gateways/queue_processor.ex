defmodule PaymentGateways.QueueProcessor do

  use GenServer
  require Logger

  alias PaymentGateways.Resolver
  alias PaymentRouter.Payments
  alias PaymentRouter.Payments.Payment


  @tick_interval 5000
  @timeout_time 20_000
  @page_size 32

  def start_link(_opts) do
    Payments.delete_all()
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_state) do
    setup_tick()

    Logger.info("[PaymentGateways.QueueProcessor] started.")

    {:ok, %{}}
  end

  defp setup_tick() do
    Process.send_after(self(), :tick, @tick_interval)
  end

  @impl true
  def handle_info(:tick, state) do

    handle()

    setup_tick()
    {:noreply, state}
  end

  defp handle() do
    payments = get_payments()
    if Enum.count(payments) > 0 do
      dispatch_payments(payments)
      handle()
    end
  end

  # Query the database for pending payments
  defp get_payments() do
    Payments.get_pending_payments(@page_size, @timeout_time)
  end

  # Send each payment asynchronously
  defp dispatch_payments(payments) do
    Enum.map(payments, fn payment ->
      Task.async(fn ->
        send_payment(payment)
      end)
    end)
    |> Task.await_many()
  end

  # Send payment using the gateway client
  defp send_payment(%Payment{} = payment) do
    Logger.info("[PaymentGateways.QueueProcessor] Sending payment #{payment.uuid}")
    {gateway_id, base_url} = Resolver.current_gateway()

    params = %{
      correlationId: payment.uuid,
      amount: payment.amount,
      requestedAt: payment.inserted_at
    }

    case PaymentGateway.Client.register_transaction(base_url, params) do
      {:ok, _resp} ->
        Payments.update_payment(payment, %{gateway_id: gateway_id})
        :ok

      {:error, reason} ->
        Logger.error("Failed to send payment: #{inspect(reason)}")
        Payments.update_payment(payment, %{retries: payment.retries + 1})

        :error
    end
  end
end
