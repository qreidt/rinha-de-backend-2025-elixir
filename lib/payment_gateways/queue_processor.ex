defmodule PaymentGateways.QueueProcessor do

  use GenServer
  require Logger

  alias PaymentGateways.Resolver
  alias PaymentRouter.Payments
  alias PaymentRouter.Payments.Payment


  @tick_interval 1000
  @timeout_time 20_000
  @page_size 128

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
    case Resolver.current_gateway() do
      {id, base_url, _, _} ->
        payments = get_payments()
        Logger.info("[PaymentGateways.QueueProcessor] payments found: #{Enum.count(payments)}")

        if Enum.count(payments) > 0 do
          dispatch_payments(payments, {id, base_url})
          handle()
        end

      _ ->
        Logger.warning("[PaymentGateways.QueueProcessor] Skipping batch due to no available gateways.")
    end
  end

  # Query the database for pending payments
  defp get_payments() do
    Payments.get_pending_payments(@page_size, @timeout_time)
  end

  # Send each payment asynchronously
  defp dispatch_payments(payments, gateway) do
    Enum.map(payments, fn payment ->
      Task.async(fn ->
        send_payment(payment, gateway)
      end)
    end)
    |> Task.await_many(10000)
  end

  # Send payment using the gateway client
  defp send_payment(%Payment{} = payment, {gateway_id, base_url}) do
    Logger.info("[PaymentGateways.QueueProcessor] Sending payment #{payment.uuid}")

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
