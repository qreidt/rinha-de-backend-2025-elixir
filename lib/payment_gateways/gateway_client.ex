defmodule PaymentGateway.Client do
  @moduledoc """
  HTTP client for Payment Gateway health checks and transaction registration.
  """

  require Logger

  @payments_path "/payments"
  @healthcheck_path "/payments/service-health"

  @doc """
  Registers a new transaction by sending a POST request to /payments.
  """
  def register_transaction(base_url, transaction_params) do
    headers = [{"Content-Type", "application/json"}]
    body = Jason.encode!(transaction_params)
    case http_client().post(base_url <> @payments_path, body, headers) do
        {:ok, %{status_code: 201, body: body}} ->
          {:ok, Jason.decode!(body)}

        {:ok, %{status_code: code, body: body}} ->
          Logger.error("Failed to register transaction: #{code} - #{body}")
          {:error, code}

        {:error, reason} ->
          Logger.error("HTTP error: #{inspect(reason)}")
          {:error, reason}
      end
  end

  @spec service_health(String.t()) :: :ok | :error
  def service_health(base_url) do
    case http_client().get(base_url <> @healthcheck_path) do

      {:ok, %{status_code: 200}} ->
        Logger.info("Payment service is healthy.")
        :ok

      {:ok, %{status_code: code}} ->
        Logger.warning("Payment service health check failed: #{code}")
        :error

      {:error, reason} ->
        Logger.error("Health check HTTP error: #{inspect(reason)}")
        :error
    end
  end

  defp http_client do
    Application.get_env(:payment_router, :http_client, HTTPoison)
  end
end
