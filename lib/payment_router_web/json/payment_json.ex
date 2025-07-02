defmodule PaymentRouterWeb.PaymentJSON do
  alias PaymentRouter.Payments.Payment

  @doc """
  Renders a list of payments.
  """
  def index(%{payments: payments}) do
    for(payment <- payments, do: data(payment))
  end

  @doc """
  Renders a single payment.
  """
  def show(%{payment: payment}) do
    %{data: data(payment)}
  end

  defp data(%Payment{} = payment) do
    %{
      id: payment.id,
      correlation_id: payment.correlation_id,
      amount: payment.amount
    }
  end
end
