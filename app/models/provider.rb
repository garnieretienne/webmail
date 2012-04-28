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

  # A Provider serve many Accounts
  has_many :accounts

  # The name and IMAP settings (address, port and SSL) must be specified
  validates :name, :imap_address, :imap_port, :imap_ssl, presence: true

  # The Provider name must be unique
  validates :name, uniqueness: true
end
