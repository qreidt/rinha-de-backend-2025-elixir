defmodule PaymentRouterWeb.Router do
  use PaymentRouterWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PaymentRouterWeb do
    pipe_through :api
    get "/payments-summary", PaymentController, :index
    post "/payments", PaymentController, :create
  end
end
