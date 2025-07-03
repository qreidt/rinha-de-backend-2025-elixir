defmodule PaymentRouter.Payments.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "payments" do
    field :amount, :decimal
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:uuid, :amount])
    |> validate_required([:uuid, :amount])
  end
end
