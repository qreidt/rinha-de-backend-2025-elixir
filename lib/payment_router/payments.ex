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

      iex> get_payment("123")
      {:ok, %Payment{}}

      iex> get_payment("456")
      ** (nil)

  """
  def get_payment(uuid) do
    Repo.get(Payment, uuid)
  end

  @doc """
  Checks if a payment already exists.

  ## Examples

      iex> payment_exists?("123")
      true

      iex> payment_exists?("456")
      false

  """
  def payment_exists?(nil), do: false
  def payment_exists?(uuid) do
    case PaymentRouter.PaymentsCache.get(uuid) do
      {:ok, _} -> true

      :not_found ->
        Repo.exists?((where(Payment, [uuid: ^uuid])))
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
    uuid = Map.get(attrs, :uuid)

    if payment_exists?(uuid) do
      :found
    else
      insert_payment(attrs)
    end
  end

  defp insert_payment(attrs) do
    result = %Payment{}
      |> Payment.changeset(attrs)
      |> Repo.insert()

    with {:ok, %Payment{} = payment} <- result do
      cache_service = get_cache_service()
      cache_service.put(payment.uuid, payment)

      {:ok, payment}
    end
  end

  def delete_all() do
    Repo.delete_all(Payment)
  end

  @spec get_summary(DateTime.t() | nil, DateTime.t() | nil) :: map()
  def get_summary(filter_start \\ nil, filter_end \\ nil) do

    filters = true
    filters = if filter_start, do: dynamic([p], p.created_at >= ^filter_start), else: filters
    filters = if filter_end, do: dynamic([p], ^filters and p.created_at <= ^filter_end), else: filters

    query =
      from p in Payment,
        group_by: p.gateway,
        select: {p.gateway, count(p.uuid), sum(p.amount)},
        where: ^filters

    Repo.all(query)
    |> Enum.reduce(base_summary(), fn
      {0, total_requests, total_amount}, acc ->
        Map.put(acc, "default", %{
          "totalRequests" => total_requests,
          "totalAmount" => Decimal.to_float(total_amount || Decimal.new(0))
        })

      {1, total_requests, total_amount}, acc ->
        Map.put(acc, "fallback", %{
          "totalRequests" => total_requests,
          "totalAmount" => Decimal.to_float(total_amount || Decimal.new(0))
        })

      _, acc -> acc
    end)
  end

  defp base_summary() do
    empty_gateway_values = %{"totalRequests" => 0, "totalAmount" => 0}
    %{"default" => empty_gateway_values, "fallback" => empty_gateway_values}
  end





  ## Deps

  defp get_cache_service() do
    Application.get_env(:payment_router, :cache_service)
  end
end
