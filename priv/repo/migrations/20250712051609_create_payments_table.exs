defmodule PaymentRouter.Repo.Migrations.CreatePaymentsTable do
  use Ecto.Migration

  def change do
    create table(:payments, primary_key: false) do
      add :uuid, :uuid, primary_key: true, autogenerate: false
      add :amount, :decimal, null: false
      add :gateway_id, :integer
      add :retries, :integer, null: false, default: 0

      timestamps(type: :utc_datetime_usec, null: false)
    end

    create index(:payments, [:gateway_id])
    create index(:payments, [:inserted_at])
  end
end
