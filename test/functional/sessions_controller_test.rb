require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  test "should get the login page" do
    get :new
    assert_response :success
  end
  
  test "should register this new account and authenticate the user (new account + right credentials)" do
    assert_difference('Account.count') do
      post :create, {email_address: 'webmail.testing.test@gmail.com', password: 'imnotstrong'}
    end
    assert session[:account_id], 'user is not logged in with right credentials and a new account'
    assert_equal assigns(:account).id, session[:account_id]
  end

  test "should not register this new account and not authenticate the user (new account + bad credentials)" do
    assert_no_difference('Account.count') do
      post :create, {email_address: 'webmail.testing.test@gmail.com', password: 'badly'}
    end
    assert !session[:account_id], 'user is logged in with bad credentials on a new account'
    assert !flash.empty?, 'user must be alerted than something goes wrong'
  end

  test "should just authenticate the user (existing account + right credentials)" do
    assert_no_difference('Account.count') do
      post :create, {email_address: accounts(:one).email_address, password: 'imnotstrong'}
    end
    assert session[:account_id], 'user is not logged in with right credentials and existing account'
    assert_equal accounts(:one).id, session[:account_id]
  end

  test "should not authenticate the user (existing account + bad credentials)" do
    assert_no_difference('Account.count') do
      post :create, {email_address: accounts(:one).email_address, password: 'badly'}
    end
    assert !session[:account_id], 'user is logged in with bad credentials on an existing account'
    assert !flash.empty?, 'user must be alerted than something goes wrong'
  end

  test "should not found any corresponding provider and not trying to authenticate the user" do
    assert_no_difference('Account.count') do
      post :create, {email_address: 'unknow@provider.tld', password: 'badly'}
    end
    assert !session[:account_id], 'user is logged in with an unknow provider'
    assert !flash.empty?, 'user must be alerted than something goes wrong'
  end

  test "should return a model error if trying to authenticate with a bad format email" do
    post :create, {email_address: 'notanemail', password: 'badly'}
    assert !assigns(:account).errors[:email_address].empty?, "error message about the email format has not been returned to the user"
  end

  test "should return a model error if trying to authenticate with a blank password" do
    post :create, {email_address: 'notanemail', password: ''}
    assert !assigns(:account).errors[:password].empty?, "error message about the password has not been returned to the user"
  end

  test "should disconnect an authenticated account" do
    session[:account_id] = accounts(:one).id
    get :destroy
    assert !session[:account_id], 'the account is not disconnected !'
  end
end
