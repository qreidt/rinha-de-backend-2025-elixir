defmodule PaymentRouterWeb.PaymentController do
  use PaymentRouterWeb, :controller

  require Logger
  alias PaymentRouter.Payments

  action_fallback PaymentRouterWeb.FallbackController

  def index(conn, params) do
    filter_start = read_datetime_filter(params, "from")
    filter_end = read_datetime_filter(params, "to")

    summary = Payments.get_summary(filter_start, filter_end)
    render(conn, :summary, summary: summary)
  end

  defp read_datetime_filter(query_params, key) do
    case Map.get(query_params, key) do
      nil -> nil
      from_str ->
        case DateTime.from_iso8601(from_str) do
          {:ok, dt, _offset} -> dt
          _ -> nil
        end
    end
  end

  def create(conn, data) do
    payment_params = %{
      uuid: data["correlationId"],
      amount: data["amount"]
    }

    case Payments.create_accepted_payment(payment_params) do
      # Payment already exists from cache
      {:cached, payment} ->
        conn
        |> put_status(:ok)
        |> render(:show, payment: payment)

      # New payment created
      {:created, payment} ->
        conn
        |> put_status(:created)
        |> render(:show, payment: payment)

      error -> error
    end
  end

  def purge(conn, _data) do
    Payments.delete_all()
    send_resp(conn, 200, "")
  end
end
