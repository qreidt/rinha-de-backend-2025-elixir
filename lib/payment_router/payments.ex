defmodule PaymentRouter.Payments do
  @moduledoc """
  The Payments context.
  """

  import Ecto.Query, warn: false
  alias PaymentRouter.Repo

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
  def get_payment(uuid), do: Repo.get(Payment, uuid)

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
    if uuid, do: Repo.get(Payment, uuid), else: nil
  end

  defp insert_payment(attrs) do
    result = %Payment{}
      |> Payment.changeset(attrs)
      |> Repo.insert()

    case result do
      {:ok, payment} -> {:created, payment}
      err -> err
    end
  end
end
