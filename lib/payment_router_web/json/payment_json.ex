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
    data(payment)
  end

  defp data(%Payment{} = payment) do
    %{
      correlationId: payment.uuid,
      amount: payment.amount
    }
  end
end
