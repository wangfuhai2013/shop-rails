require 'test_helper'

module Shop
  class ProductPropertiesControllerTest < ActionController::TestCase
    setup do
      @product_property = product_properties(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:product_properties)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create product_property" do
      assert_difference('ProductProperty.count') do
        post :create, product_property: { input_value: @product_property.input_value, product_id: @product_property.product_id, product_sku_id: @product_property.product_sku_id, property_id: @product_property.property_id, property_value_id: @product_property.property_value_id }
      end

      assert_redirected_to product_property_path(assigns(:product_property))
    end

    test "should show product_property" do
      get :show, id: @product_property
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @product_property
      assert_response :success
    end

    test "should update product_property" do
      patch :update, id: @product_property, product_property: { input_value: @product_property.input_value, product_id: @product_property.product_id, product_sku_id: @product_property.product_sku_id, property_id: @product_property.property_id, property_value_id: @product_property.property_value_id }
      assert_redirected_to product_property_path(assigns(:product_property))
    end

    test "should destroy product_property" do
      assert_difference('ProductProperty.count', -1) do
        delete :destroy, id: @product_property
      end

      assert_redirected_to product_properties_path
    end
  end
end
