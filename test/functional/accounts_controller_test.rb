require 'test_helper'

class AccountsControllerTest < ActionController::TestCase

  # Method to fake authentication
  def authenticate
    account = accounts(:one)
    session[:account_id] = account.id
  end

  test "should get show" do
    authenticate
    get :show
    assert_response :success
  end

  test "should be redirected to the login page if not authenticated" do
    get :show
    assert_response :redirect
  end

end
