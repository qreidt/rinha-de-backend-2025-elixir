defmodule PaymentRouter.PaymentsTest do
  use PaymentRouter.DataCase

  alias PaymentRouter.Payments

  describe "payments" do
    alias PaymentRouter.Payments.Payment

    import PaymentRouter.PaymentsFixtures

    @invalid_attrs %{uuid: nil, amount: nil}

    test "list_payments/0 returns all payments" do
      payment = payment_fixture()
      assert Payments.list_payments() == [payment]
    end

    test "get_payment/1 returns the payment with given id" do
      payment = payment_fixture()
      assert Payments.get_payment(payment.uuid) == payment
    end

    test "create_payment/1 with valid data creates a payment" do
      valid_attrs = %{uuid: "7488a646-e31f-11e4-aace-600308960662", amount: "120.5"}

      assert {:created, %Payment{} = payment} = Payments.create_payment(valid_attrs)
      assert payment.uuid == "7488a646-e31f-11e4-aace-600308960662"
      assert payment.amount == Decimal.new("120.5")
    end

    test "create_payment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Payments.create_payment(@invalid_attrs)
    end
  end
end
