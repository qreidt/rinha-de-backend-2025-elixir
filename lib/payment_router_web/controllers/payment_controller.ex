defmodule PaymentRouterWeb.PaymentController do
  use PaymentRouterWeb, :controller

  alias PaymentRouter.Payments

  action_fallback PaymentRouterWeb.FallbackController

  @spec index(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def index(conn, _params) do
    payments = Payments.list_payments()
    render(conn, :index, payments: payments)
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, data) do

    payment_params = %{
      uuid: data["correlationId"],
      amount: data["amount"]
    }

    case Payments.create_payment(payment_params) do
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
end
