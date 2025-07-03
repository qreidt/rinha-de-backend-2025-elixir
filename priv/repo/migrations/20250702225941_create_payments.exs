defmodule PaymentRouter.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments, primary_key: false) do
      add :uuid, :uuid, primary_key: true, autogenerate: false
      add :amount, :decimal
    end
  end
end
