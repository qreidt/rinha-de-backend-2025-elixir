defmodule PaymentRouterWeb.Router do
  use PaymentRouterWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", PaymentRouterWeb do
    pipe_through :api
  end
end
