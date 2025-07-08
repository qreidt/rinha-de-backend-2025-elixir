defmodule PaymentRouterWeb.PaymentController do
  use PaymentRouterWeb, :controller

  require Logger
  alias PaymentRouter.Payments

  action_fallback PaymentRouterWeb.FallbackController

  def index(conn, _params) do
    payments = Payments.list_accepted_payments()
    render(conn, :index, payments: payments)
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
