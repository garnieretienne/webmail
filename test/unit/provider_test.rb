require 'test_helper'

class ProviderTest < ActiveSupport::TestCase

  test "provider name must be unique" do
  	provider1 = Provider.new(name: 'test.com', imap_address: 'imap.test.com', imap_port: 993, imap_ssl: true)
  	assert provider1.save, 'this provider must be correctly saved'
  	provider2 = Provider.new(name: 'test.com', imap_address: 'imap2.test.com', imap_port: 993, imap_ssl: true)
  	assert !provider2.save, 'this provider is already registered, it must not be saved !'
  end
end
