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
      assert_equal NET::IMAP, imap.class
    end
  end

  test "sync: should sync the mailboxes cache (many new, one deleted)" do
    account = accounts(:one)
    account.password = "imnotstrong"
    assert account.sync
    assert (account.mailboxes.count > 2), "no mailboxes has been imported"
    assert !account.mailboxes.find_by_name('test'), "the test mailbox is not present on the server but still exist"
  end
end
