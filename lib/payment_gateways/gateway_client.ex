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
    Logger.info("[PaymentGateway.Client][#{base_url}] >>> #{transaction_params.correlationId}")
    headers = [{"Content-Type", "application/json"}]
    body = Jason.encode!(transaction_params)

    case http_client().post(base_url <> @payments_path, body, headers) do
        {:ok, %{status_code: 200, body: body}} ->
          Logger.info("[PaymentGateway.Client][#{base_url}] <<< #{body}")
          {:ok, Jason.decode!(body)}

        {:ok, %{status_code: code, body: body}} ->
          Logger.error("Failed to register transaction: #{code} - #{body}")
          {:error, code}

        {:error, reason} ->
          {:error, reason}
      end
  end

  @spec service_health(String.t()) :: {:ok, boolean(), integer()} | :error
  def service_health(base_url) do
    case http_client().get(base_url <> @healthcheck_path) do

      {:ok, %{status_code: 200, body: body}} ->
        %{"failing" => failing, "minResponseTime" => response_time} = Jason.decode!(body)
        {:ok, failing, response_time}

      {:ok, %{status_code: code}} ->
        Logger.warning("[PaymentGateway.Client][#{base_url}] Payment service health check failed: #{code}")
        :error

      {:error, reason} ->
        Logger.error("[PaymentGateway.Client][#{base_url}] Health check HTTP error: #{inspect(reason)}")
        :error
    end
  end

  defp http_client do
    Application.get_env(:payment_router, :http_client, HTTPoison)
  end
end
