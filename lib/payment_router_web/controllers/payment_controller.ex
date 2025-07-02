defmodule PaymentRouterWeb.PaymentController do
  use PaymentRouterWeb, :controller

  alias PaymentRouter.Payments
  alias PaymentRouter.Payments.Payment

  action_fallback PaymentRouterWeb.FallbackController

  @spec index(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def index(conn, _params) do
    payments = Payments.list_payments()
    render(conn, :index, payments: payments)
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, data) do

    payment_params = %{
      "correlation_id" => data["correlationId"],
      "amount" => data["amount"]
    }

    with {:ok, %Payment{} = payment} <- Payments.create_payment(payment_params) do
      conn
      |> put_status(:created)
      |> render(:show, payment: payment)
    end
  end
end
