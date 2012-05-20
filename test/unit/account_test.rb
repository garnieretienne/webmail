require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  test "email address must be present" do
  	account = Account.new(provider: Provider.first)
  	assert !account.valid?, "an account without email address must not be valid"
  end

  test "a provider must be specified" do
  	account = Account.new(email_address: 'user@domain.tld')
  	assert !account.valid?, "an account without provider must not be valid"
  end

  test "email address must be unique" do
    account = Account.new(email_address: 'webmail.testing.dev@gmail.com', provider: Provider.first)
  	assert !account.valid?, "an account with the same email address is already registered in the database, it must not be valid"
  end

  test "email address must be in a correct format (user@domain.tld)" do
  	account = Account.new(email_address: 'webmail.testing.dev', provider: Provider.first)
  	assert !account.valid?, "this account is valid with a bad email syntax"
  end

  test "password must be a virtual attribute" do
  	account = Account.new(email_address: 'qwerty@gmail.com', provider: Provider.first)
  	account.password = '1234'
  	assert_equal account.password, '1234'
  end

  test "must authenticate an user" do
  	account = accounts(:one)
  	account.password = 'imnotstrong'
  	assert account.authenticate, "user is not authenticated using the right password"
  end

  test "must refuse to identicate an user with false credentials" do
  	account = accounts(:one)
  	account.password = 'badly'
  	assert !account.authenticate, "user is authenticated using a bad password"
  end

  test "should connect to the account's provider server and authenticate on it" do
    account = accounts(:one)
    account.password = 'imnotstrong'
    account.connect do |imap|
      assert_equal Net::IMAP, imap.class
    end
  end

  test "should connect to the account provider server, authenticate on it, and return an Net::IMAP object" do
    account = accounts(:one)
    account.password = 'imnotstrong'
    imap = account.connect 
    assert_equal Net::IMAP, imap.class
    assert imap.logout
  end

  test "mailboxes synchronization" do
    account = accounts(:one)
    account.password = 'imnotstrong'
    imap = account.connect

    # Should add this mailbox into the cache
    add_mailbox(accounts(:one).email_address, "Testing")
    account.sync_mailboxes imap
    assert_not_nil account.mailboxes.find_by_name("Testing")

    # Should remove this mailbox from the cache
    delete_mailbox(accounts(:one).email_address, "Testing")
    account.sync_mailboxes imap
    assert_nil account.mailboxes.find_by_name("Testing")
  end
end
