# This class is an Active Record object to manage all settings for email service providers.
# We can easily retrieve IMAP settings from it.
#   gmail = Provider.new(name: 'gmail.com', imap_address: 'imap.gmail.com', imap_port: 993, imap_ssl: true)
#   gmail.ssl?         => 'true'
#   gmail.imap_address => 'imap.gmail.com'
#
# These data are seeded into the db/seeds.rb file.
class Provider < ActiveRecord::Base
  attr_accessible :imap_address, :imap_port, :imap_ssl, :name

  validates :name, uniqueness: true
end
