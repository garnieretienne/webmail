require 'test_helper'

class Api::MailboxesControllerTest < ActionController::TestCase

  # Method to simulate the user authentification
  def authenticate!
    session[:account_id] = accounts(:one).id
  end

  test "should return a forbidden action trying to use the api without being authenticated before" do
    xhr :get, :index
    assert_response :forbidden
  end

  test "should return a list of mailboxes for this account (in json)" do
    authenticate!
    xhr :get, :index, format: :json
    assert_response :success
    assert_equal "Test", json_response.first['name']
  end

  test "json model should return flags array" do
    authenticate!
    xhr :get, :index, format: :json
    assert_equal ["Hasnochildren", "Noselect"], json_response.first['flags']
  end

  test "json model shouldnot return flag_attr and account_id" do
    authenticate!
    xhr :get, :index, format: :json
    assert !json_response.first['flag_attr']
    assert !json_response.first['account_id']
  end
end
