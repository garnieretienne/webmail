require 'test_helper'

class AccountsControllerTest < ActionController::TestCase

  # Method to fake authentication
  def authenticate
    session[:account_id] = accounts(:one).id
    session[:password] = 'imnotstrong'
  end

  test "should get show" do
    authenticate
    get :show
    assert_response :success
  end

  test "should be redirected to the login page if not authenticated" do
    get :show
    assert_response :redirect
    get :sync
    assert_response :redirect
  end

  test "should synchronize the current account state with the server" do
    authenticate
    assert_equal 3, accounts(:one).mailboxes.count
    get :sync
    assert_response :success
    assert_equal 11, assigns(:account).mailboxes.count
  end

end
