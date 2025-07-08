defmodule PaymentRouter.Payments.AcceptedPayment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "accepted_payments" do
    field :amount, :decimal
    field :retries, :integer
    field :created_at, :utc_datetime_usec
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:uuid, :amount])
    |> validate_required([:uuid, :amount])
  end
end
