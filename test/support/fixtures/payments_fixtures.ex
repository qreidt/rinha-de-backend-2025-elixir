defmodule PaymentRouter.PaymentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PaymentRouter.Payments` context.
  """

  @doc """
  Generate a payment.
  """
  def payment_fixture(attrs \\ %{}) do
    {:created, payment} =
      attrs
      |> Enum.into(%{
        amount: "120.5",
        uuid: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> PaymentRouter.Payments.create_payment()

    payment
  end
end
