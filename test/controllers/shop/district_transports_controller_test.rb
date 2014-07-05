require 'test_helper'

module Shop
  class DistrictTransportsControllerTest < ActionController::TestCase
    setup do
      @district_transport = district_transports(:one)
    end

    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:district_transports)
    end

    test "should get new" do
      get :new
      assert_response :success
    end

    test "should create district_transport" do
      assert_difference('DistrictTransport.count') do
        post :create, district_transport: { district_id: @district_transport.district_id, fee: @district_transport.fee }
      end

      assert_redirected_to district_transport_path(assigns(:district_transport))
    end

    test "should show district_transport" do
      get :show, id: @district_transport
      assert_response :success
    end

    test "should get edit" do
      get :edit, id: @district_transport
      assert_response :success
    end

    test "should update district_transport" do
      patch :update, id: @district_transport, district_transport: { district_id: @district_transport.district_id, fee: @district_transport.fee }
      assert_redirected_to district_transport_path(assigns(:district_transport))
    end

    test "should destroy district_transport" do
      assert_difference('DistrictTransport.count', -1) do
        delete :destroy, id: @district_transport
      end

      assert_redirected_to district_transports_path
    end
  end
end
