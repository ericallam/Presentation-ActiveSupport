require 'test_helper'

class PageRequestsControllerTest < ActionController::TestCase
  setup do
    @page_request = page_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:page_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create page_request" do
    assert_difference('PageRequest.count') do
      post :create, page_request: { duration: @page_request.duration, end_time: @page_request.end_time, start_time: @page_request.start_time }
    end

    assert_redirected_to page_request_path(assigns(:page_request))
  end

  test "should show page_request" do
    get :show, id: @page_request
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @page_request
    assert_response :success
  end

  test "should update page_request" do
    put :update, id: @page_request, page_request: { duration: @page_request.duration, end_time: @page_request.end_time, start_time: @page_request.start_time }
    assert_redirected_to page_request_path(assigns(:page_request))
  end

  test "should destroy page_request" do
    assert_difference('PageRequest.count', -1) do
      delete :destroy, id: @page_request
    end

    assert_redirected_to page_requests_path
  end
end
