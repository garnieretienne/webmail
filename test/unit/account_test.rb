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
  	account = Account.new(email_address: 'qwerty@gmail.com', provider: Provider.first, password: '1234')
  	assert_equal account.password, '1234'
  end
end
