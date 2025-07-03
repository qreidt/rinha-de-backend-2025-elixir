defmodule PaymentRouter.Payments do
  @moduledoc """
  The Payments context.
  """

  import Ecto.Query, warn: false
  alias PaymentRouter.Repo

  alias PaymentRouter.PaymentsCache
  alias PaymentRouter.Payments.Payment

  @doc """
  Returns the list of payments.

  ## Examples

      iex> list_payments()
      [%Payment{}, ...]

  """
  def list_payments do
    Repo.all(Payment)
  end

  @doc """
  Gets a single payment.

  Returns nil if the Payment does not exist.

  ## Examples

      iex> get_payment(123)
      %Payment{}

      iex> get_payment(456)
      ** (nil)

  """
  def get_payment(uuid) do
  case PaymentRouter.PaymentsCache.get(uuid) do
    {:ok, payment} -> payment

    :not_found ->
      payment = Repo.get(Payment, uuid)
      if payment, do: PaymentsCache.put(uuid, payment)
      payment
  end
end

  @doc """
  Creates a payment.

  ## Examples

      iex> create_payment(%{field: value})
      {:ok, %Payment{}}

      iex> create_payment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_payment(attrs \\ %{}) do
    case get_payment_by_attrs(attrs) do
      nil -> insert_payment(attrs)
      payment -> {:cached, payment}
    end
  end

  defp get_payment_by_attrs(attrs) do
    uuid = Map.get(attrs, :uuid)
    if uuid, do: get_payment(uuid), else: nil
  end

  defp insert_payment(attrs) do
    result = %Payment{}
      |> Payment.changeset(attrs)
      |> Repo.insert()

    with {:ok, %Payment{} = payment} <- result do
      PaymentsCache.put(payment.uuid, payment)

      {:created, payment}
    end
  end
end
