require 'test_helper'

module Shop
  class DeliveryItemsControllerTest < ActionController::TestCase
    setup do
      @delivery_item = delivery_items(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:delivery_items)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create delivery_item" do
      assert_difference('DeliveryItem.count') do
        post :create, delivery_item: { delivery_id: @delivery_item.delivery_id, product_sku_id: @delivery_item.product_sku_id, quantity: @delivery_item.quantity }
      end

      assert_redirected_to delivery_item_path(assigns(:delivery_item))
    end

    test "should show delivery_item" do
      get :show, id: @delivery_item
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @delivery_item
      assert_response :success
    end

    test "should update delivery_item" do
      patch :update, id: @delivery_item, delivery_item: { delivery_id: @delivery_item.delivery_id, product_sku_id: @delivery_item.product_sku_id, quantity: @delivery_item.quantity }
      assert_redirected_to delivery_item_path(assigns(:delivery_item))
    end

    test "should destroy delivery_item" do
      assert_difference('DeliveryItem.count', -1) do
        delete :destroy, id: @delivery_item
      end

      assert_redirected_to delivery_items_path
    end
  end
end
