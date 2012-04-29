require 'test_helper'

class ProviderTest < ActiveSupport::TestCase

  test "provider name must be present" do
  	provider = Provider.new(imap_address: 'imap.test.com', imap_port: 993, imap_ssl: true)
  	assert !provider.valid?, "a provider without a name must not be valid"
  end

  test "an imap server address must be present" do
  	provider = Provider.new(name: 'test.com', imap_port: 993, imap_ssl: true)
  	assert !provider.valid?, "a provider without an IMAP address must not be valid"
  end  
  
  test "an imap server port must be present" do
  	provider = Provider.new(name: 'test.com', imap_address: 'imap.test.com', imap_ssl: true)
  	assert provider.valid?, "no default value are enabled for the IMAP port"
  	assert_equal provider.imap_port, 993
  end

  test "an imap server SSL indicator must be present" do
  	provider = Provider.new(name: 'test.com', imap_address: 'imap.test.com', imap_port: 993)
  	assert provider.valid?, "no default value are enabled for the SSL indicator"
  	assert provider.imap_ssl, "the default value must be true"
  end

  test "provider name must be unique" do
  	provider1 = Provider.new(name: 'test.com', imap_address: 'imap.test.com', imap_port: 993, imap_ssl: true)
  	assert provider1.save, 'this provider must be correctly saved'
  	provider2 = Provider.new(name: 'test.com', imap_address: 'imap2.test.com', imap_port: 993, imap_ssl: true)
  	assert !provider2.save, 'this provider is already registered, it must not be saved !'
  end

  test "should find a provider for this email" do
  	provider = Provider.find_for('test@gmail.com')
  	assert_equal 'gmail.com', provider.name
  end

  test "should not find a provider for this email" do
  	assert !Provider.find_for('test@custom.com')
  end

  test "should return an IMAP connection" do
  	connection = Provider.first.connect
  	assert_equal Net::IMAP, connection.class
  	connection.logout if connection
  end

  test "should return an error if the IMAP connection fail" do
  	provider = Provider.first
  	provider.imap_address = 'localhost'
  	connection = provider.connect
  	assert !connection, "do not return false on a failed connection"
  	connection.logout if connection
  end
end
