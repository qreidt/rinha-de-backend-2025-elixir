defmodule PaymentRouterWeb.PaymentControllerTest do
  use PaymentRouterWeb.ConnCase

  @create_attrs %{
    correlationId: "7488a646-e31f-11e4-aace-600308960662",
    amount: "120.5"
  }

  @invalid_attrs %{correlation_id: nil, amount: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all payments", %{conn: conn} do
      conn = get(conn, ~p"/payments-summary")
      assert json_response(conn, 200) == []
    end
  end

  describe "create payment" do
    test "renders payment when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/payments", @create_attrs)
      response_data = json_response(conn, 201)

      assert ^response_data = %{
        "amount" => "120.5",
        "correlationId" => "7488a646-e31f-11e4-aace-600308960662"
      }
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/payments", @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
