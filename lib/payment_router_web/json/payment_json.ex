defmodule PaymentRouterWeb.PaymentJSON do
  alias PaymentRouter.Payments.AcceptedPayment

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

  defp data(%AcceptedPayment{} = payment) do
    %{
      correlationId: payment.uuid,
      amount: payment.amount
    }
  end

  def summary(%{summary: summary}) do
    summary
  end
end
