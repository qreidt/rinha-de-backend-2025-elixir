defmodule PaymentRouter.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:processed_payments, primary_key: false) do
      add :uuid, :uuid, primary_key: true, autogenerate: false
      add :amount, :decimal
      add :gateway, :integer
      add :created_at, :utc_datetime_usec, default: "NOW()"
    end

    create index(:processed_payments, [:created_at])
  end
end
