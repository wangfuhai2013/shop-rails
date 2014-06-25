require 'test_helper'

module Shop
  class OneProductsControllerTest < ActionController::TestCase
    setup do
      @shop_one_product = shop_one_products(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:shop_one_products)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create shop_one_product" do
      assert_difference('Shop::OneProduct.count') do
        post :create, shop_one_product: { account_id: @shop_one_product.account_id, is_closed: @shop_one_product.is_closed, issue_no: @shop_one_product.issue_no, join_person_time: @shop_one_product.join_person_time, price: @shop_one_product.price, product_id: @shop_one_product.product_id, result_code: @shop_one_product.result_code, result_member_id: @shop_one_product.result_member_id, result_time: @shop_one_product.result_time }
      end

      assert_redirected_to shop_one_product_path(assigns(:shop_one_product))
    end

    test "should show shop_one_product" do
      get :show, id: @shop_one_product
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @shop_one_product
      assert_response :success
    end

    test "should update shop_one_product" do
      patch :update, id: @shop_one_product, shop_one_product: { account_id: @shop_one_product.account_id, is_closed: @shop_one_product.is_closed, issue_no: @shop_one_product.issue_no, join_person_time: @shop_one_product.join_person_time, price: @shop_one_product.price, product_id: @shop_one_product.product_id, result_code: @shop_one_product.result_code, result_member_id: @shop_one_product.result_member_id, result_time: @shop_one_product.result_time }
      assert_redirected_to shop_one_product_path(assigns(:shop_one_product))
    end

    test "should destroy shop_one_product" do
      assert_difference('Shop::OneProduct.count', -1) do
        delete :destroy, id: @shop_one_product
      end

      assert_redirected_to shop_one_products_path
    end
  end
end
