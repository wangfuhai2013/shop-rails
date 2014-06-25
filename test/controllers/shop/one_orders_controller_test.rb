require 'test_helper'

module Shop
  class OneOrdersControllerTest < ActionController::TestCase
    setup do
      @shop_one_order = shop_one_orders(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:shop_one_orders)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create shop_one_order" do
      assert_difference('Shop::OneOrder.count') do
        post :create, shop_one_order: { got_code_quantity: @shop_one_order.got_code_quantity, is_got_all_code: @shop_one_order.is_got_all_code, is_paid: @shop_one_order.is_paid, member_id: @shop_one_order.member_id, one_product_id: @shop_one_order.one_product_id, order_person_time: @shop_one_order.order_person_time, pay_time: @shop_one_order.pay_time, pay_way: @shop_one_order.pay_way, trade_no: @shop_one_order.trade_no }
      end

      assert_redirected_to shop_one_order_path(assigns(:shop_one_order))
    end

    test "should show shop_one_order" do
      get :show, id: @shop_one_order
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @shop_one_order
      assert_response :success
    end

    test "should update shop_one_order" do
      patch :update, id: @shop_one_order, shop_one_order: { got_code_quantity: @shop_one_order.got_code_quantity, is_got_all_code: @shop_one_order.is_got_all_code, is_paid: @shop_one_order.is_paid, member_id: @shop_one_order.member_id, one_product_id: @shop_one_order.one_product_id, order_person_time: @shop_one_order.order_person_time, pay_time: @shop_one_order.pay_time, pay_way: @shop_one_order.pay_way, trade_no: @shop_one_order.trade_no }
      assert_redirected_to shop_one_order_path(assigns(:shop_one_order))
    end

    test "should destroy shop_one_order" do
      assert_difference('Shop::OneOrder.count', -1) do
        delete :destroy, id: @shop_one_order
      end

      assert_redirected_to shop_one_orders_path
    end
  end
end
