require 'test_helper'

module Shop
  class ProductSkusControllerTest < ActionController::TestCase
    setup do
      @product_sku = product_skus(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:product_skus)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create product_sku" do
      assert_difference('ProductSku.count') do
        post :create, product_sku: { price: @product_sku.price, product_id: @product_sku.product_id, quantity: @product_sku.quantity, sku_code: @product_sku.sku_code }
      end

      assert_redirected_to product_sku_path(assigns(:product_sku))
    end

    test "should show product_sku" do
      get :show, id: @product_sku
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @product_sku
      assert_response :success
    end

    test "should update product_sku" do
      patch :update, id: @product_sku, product_sku: { price: @product_sku.price, product_id: @product_sku.product_id, quantity: @product_sku.quantity, sku_code: @product_sku.sku_code }
      assert_redirected_to product_sku_path(assigns(:product_sku))
    end

    test "should destroy product_sku" do
      assert_difference('ProductSku.count', -1) do
        delete :destroy, id: @product_sku
      end

      assert_redirected_to product_skus_path
    end
  end
end
