defmodule PaymentRouter.Payments.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "payments" do
    field :correlation_id, Ecto.UUID
    field :amount, :decimal

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:correlation_id, :amount])
    |> validate_required([:correlation_id, :amount])
  end
end
