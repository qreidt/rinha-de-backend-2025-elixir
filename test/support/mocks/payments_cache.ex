defmodule PaymentRouter.PaymentsCacheMock do

  @spec get(String.t()) :: :not_found
  def get(_uuid) do
    :not_found
  end

  @spec put(String.t(), %PaymentRouter.Payments.Payment{}) :: :ok
  def put(_uuid, _payment) do
    :ok
  end
end
