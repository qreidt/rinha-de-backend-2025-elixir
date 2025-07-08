defmodule PaymentRouter.Payments.ProcessedPayment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "processed_payments" do
    field :amount, :decimal
    field :gateway, :integer

    field :created_at, :utc_datetime # make auto-created with now()
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:uuid, :amount, :gateway])
    |> validate_required([:uuid, :amount, :gateway])
  end
end
