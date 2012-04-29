# This class is an Active Record object to manage all settings for email service providers.
# We can easily retrieve IMAP settings from it.
#   gmail = Provider.new(name: 'gmail.com', imap_address: 'imap.gmail.com', imap_port: 993, imap_ssl: true)
#   gmail.ssl?         => 'true'
#   gmail.imap_address => 'imap.gmail.com'
#
# These data are seeded into the db/seeds.rb file.
# Default values for imap_port and imap_ssl are defined in the migration file.
#   imap_port: 993
#   imap_ssl:  true
class Provider < ActiveRecord::Base
  attr_accessible :imap_address, :imap_port, :imap_ssl, :name

  # Use Net::IMAP functionnalities
  require 'net/imap'

  # A Provider serve many Accounts
  has_many :accounts

  # The name and IMAP settings (address, port and SSL) must be specified
  validates :name, :imap_address, :imap_port, :imap_ssl, presence: true

  # The Provider name must be unique
  validates :name, uniqueness: true

  # Analyze the email address and return the good Provider.
  # If no Provider is found for this email address, must return false.
  #   account = Account.new(email_address: "test@gmail.com")
  #   provider = Provider.find_for test@gmail.com
  #   if provider
  #     ... a provider has been found ...
  #     account.provider = provider
  #   else
  #     ... no provider found ...
  #   end 
  def self.find_for(email_address)
  	domain_name = email_address.split('@').last
  	provider = Provider.find_by_name(domain_name)
  	return (provider) ? provider : false
  end

  # Connect to the Provider IMAP server
  # On failed connection, do not show an error but return false.
  # see: http://ruby-doc.org/stdlib-1.9.3/libdoc/net/imap/rdoc/Net/IMAP.html#method-c-new
  #   provider = Provider.new(name: 'gmail', imap_address: 'imap.gmail.com', imap_port: '993', imap_ssl: true)
  #   connection = provider.connect
  def connect
  	begin
  	  return Net::IMAP.new(self.imap_address, port: self.imap_port, ssl: self.imap_ssl)
  	rescue
  		return false
  	end
  end
end
