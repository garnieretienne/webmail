require 'test_helper'

class Api::MessagesControllerTest < ActionController::TestCase

  # Method to simulate the user authentification
  def authenticate!
    session[:account_id] = accounts(:one).id
    session[:password] = 'imnotstrong'
  end

  test "should return a forbidden action trying to use the api without being authenticated before" do
    xhr :get, :index
    assert_response :forbidden
  end

  test "should return a list of messages for the given mailbox (in json)" do
    authenticate!
    xhr :get, :index, format: :json, mailbox_id: mailboxes(:inbox).id
    assert_response :success
    assert_equal "webmail@yuweb.fr", json_response.first['from_address']
  end

  test "json model should return flags array" do
    authenticate!
    xhr :get, :index, format: :json, mailbox_id: mailboxes(:inbox).id
    assert_equal ["Recent", "Seen"], json_response.first['flags']
  end

  test "json model should not return flag_attr and account_id" do
    authenticate!
    xhr :get, :index, format: :json, mailbox_id: mailboxes(:inbox).id
    assert !json_response.first['flag_attr'], "the json response contain the flag_attr"
    assert !json_response.first['body'], "the json response contain the message body"
  end

  test "the json elements of a message (on show)" do
    authenticate!
    xhr :get, :show, format: :json, mailbox_id: mailboxes(:inbox).id, id: messages(:one).id
    assert_response :success
    assert json_response['subject'], "the json response contain the message subject"
  end
end
