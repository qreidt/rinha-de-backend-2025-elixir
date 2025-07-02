defmodule PaymentRouter.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :correlation_id, :uuid
      add :amount, :decimal

      timestamps(type: :utc_datetime)
    end
  end
end
