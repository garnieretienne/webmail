require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  
  test "should register this new account and authenticate the user (new account + right credentials)" do
    assert_difference('Account.count') do
      post :create, {email_address: 'webmail.testing.test@gmail.com', password: 'imnotstrong'}
    end
    assert session[:account], 'user is not logged in with right credentials and a new account'
    assert_equal 'webmail.testing.test@gmail.com', session[:account].email_address
  end

  test "should not register this new account and not authenticate the user (new account + bad credentials)" do
    assert_no_difference('Account.count') do
      post :create, {email_address: 'webmail.testing.test@gmail.com', password: 'badly'}
    end
    assert !session[:account], 'user is logged in with bad credentials on a new account'
  end

  test "should just authenticate the user (existing account + right credentials)" do
    assert_no_difference('Account.count') do
      post :create, {email_address: accounts(:one).email_address, password: 'imnotstrong'}
    end
    assert session[:account], 'user is not logged in with right credentials and existing account'
    assert_equal accounts(:one).email_address, session[:account].email_address
  end

  test "should not authenticate the user (existing account + bad credentials)" do
    assert_no_difference('Account.count') do
      post :create, {email_address: accounts(:one).email_address, password: 'badly'}
    end
    assert !session[:account], 'user is logged in with bad credentials on an existing account'
  end

  # test with a false email or a blank password
end
