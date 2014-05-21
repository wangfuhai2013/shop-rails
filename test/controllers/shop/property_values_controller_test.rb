require 'test_helper'

module Shop
  class PropertyValuesControllerTest < ActionController::TestCase
    setup do
      @property_value = property_values(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:property_values)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create property_value" do
      assert_difference('PropertyValue.count') do
        post :create, property_value: { is_enabled: @property_value.is_enabled, property_id: @property_value.property_id, the_order: @property_value.the_order, value: @property_value.value }
      end

      assert_redirected_to property_value_path(assigns(:property_value))
    end

    test "should show property_value" do
      get :show, id: @property_value
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @property_value
      assert_response :success
    end

    test "should update property_value" do
      patch :update, id: @property_value, property_value: { is_enabled: @property_value.is_enabled, property_id: @property_value.property_id, the_order: @property_value.the_order, value: @property_value.value }
      assert_redirected_to property_value_path(assigns(:property_value))
    end

    test "should destroy property_value" do
      assert_difference('PropertyValue.count', -1) do
        delete :destroy, id: @property_value
      end

      assert_redirected_to property_values_path
    end
  end
end
