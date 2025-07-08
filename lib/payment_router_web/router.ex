defmodule PaymentRouterWeb.Router do
  use PaymentRouterWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PaymentRouterWeb do
    pipe_through :api
    post "/payments", PaymentController, :create
    get "/payments-summary", PaymentController, :index

    post "/purge-payments", PaymentController, :purge
  end
end
