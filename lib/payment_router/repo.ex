defmodule PaymentRouter.Repo do
  use Ecto.Repo,
    otp_app: :payment_router,
    adapter: Ecto.Adapters.Postgres
end
