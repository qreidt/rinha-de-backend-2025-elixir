defmodule PaymentRouter.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:accepted_payments, primary_key: false) do
      add :uuid, :uuid, primary_key: true, autogenerate: false
      add :amount, :decimal
      add :retries, :integer, default: 0
      add :created_at, :utc_datetime_usec, default: "NOW()"
    end

    create index(:accepted_payments, [:created_at])
  end
end
