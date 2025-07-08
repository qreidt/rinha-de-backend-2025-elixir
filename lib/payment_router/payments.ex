defmodule PaymentRouter.Payments do
  @moduledoc """
  The Payments context.
  """

  import Ecto.Query, warn: false
  alias PaymentRouter.Repo

  alias PaymentRouter.Payments.AcceptedPayment

  @doc """
  Returns the list of payments.

  ## Examples

      iex> list_payments()
      [%AcceptedPayment{}, ...]

  """
  def list_accepted_payments do
    Repo.all(AcceptedPayment)
  end

  @doc """
  Gets a single payment.

  Returns nil if the AcceptedPayment does not exist.

  ## Examples

      iex> get_accepted_payment(123)
      %AcceptedPayment{}

      iex> get_accepted_payment(456)
      ** (nil)

  """
  def get_accepted_payment(uuid) do
  case PaymentRouter.PaymentsCache.get(uuid) do
    {:ok, payment} -> payment

    :not_found ->
      payment = Repo.get(AcceptedPayment, uuid)
      cache_service = get_cache_service()
      if payment, do: cache_service.put(uuid, payment)
      payment
  end
end

  @doc """
  Creates a payment.

  ## Examples

      iex> create_accepted_payment(%{field: value})
      {:ok, %AcceptedPayment{}}

      iex> create_accepted_payment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_accepted_payment(attrs \\ %{}) do
    case get_payment_by_attrs(attrs) do
      nil -> insert_accepted_payment(attrs)
      payment -> {:cached, payment}
    end
  end

  defp get_payment_by_attrs(attrs) do
    uuid = Map.get(attrs, :uuid)
    if uuid, do: get_accepted_payment(uuid), else: nil
  end

  defp insert_accepted_payment(attrs) do
    result = %AcceptedPayment{}
      |> AcceptedPayment.changeset(attrs)
      |> Repo.insert()

    with {:ok, %AcceptedPayment{} = payment} <- result do
      cache_service = get_cache_service()
      cache_service.put(payment.uuid, payment)

      {:created, payment}
    end
  end

  def delete_all() do
    Repo.delete_all(AcceptedPayment)
  end

  ## Deps

  defp get_cache_service() do
    Application.get_env(:payment_router, :cache_service)
  end
end
