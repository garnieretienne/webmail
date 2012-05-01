# This class is an Active Record object to store accounts credentials on an email service provider.
# It store an email address and a password, used to connect on the user's IMAP account.
# Only the email address is stored in database, the password is a virtual attribute and is 
# only used to initiate the IMAP connection.
class Account < ActiveRecord::Base
  attr_accessible :email_address, :provider

  # Virtual attribute: password
  attr_accessor :password

  # An Account belong to one Provider
  # and own many mailboxes
  belongs_to :provider
  has_many :mailboxes

  # The email address and the provider must be specified
  validates :email_address, :provider_id, :password, presence: true

  # The email address must be unique and in a good format (user@domain.tld)
  validates :email_address, email_format: true
  validates :email_address, uniqueness: true, on: :create
  
  # Authenticate an user using his IMAP credentials.
  # Authentication use the 'LOGIN' command to authenticate on the IMAP server.
  # see: http://ruby-doc.org/stdlib-1.9.3/libdoc/net/imap/rdoc/Net/IMAP.html#method-i-login
  # On failed authentication, do not show an error but return false.
  # On successfull authentication, return true and set the session variable 'account'.
  # TODO: Works better with IMAP and Socket errors:
  #  - Net::IMAP::NoResponseError (IMAP)
  #  - Net::IMAP::BadResponseError (IMAP)
  #  - Net::IMAP::ByeResponseError (IMAP)
  #  - Errno (Socket)
  def authenticate
    self.provider.connect do |imap|
      begin
        imap.login(self.email_address, self.password)
        return true
      rescue Net::IMAP::NoResponseError 
        return false
      end  
    end
  end

  # Connect to the account's provider server and authenticate on it.
  #   account = Account.find_by_email(email_address)
  #   account.password = password
  #   account.connect do
  #     ... do your stuff ...
  #   end
  def connect
    self.provider.connect do |imap|
      imap.login(self.email_address, self.password)
      yield imap
    end
  end

  # Sync all mailboxes from the IMAP server.
  # All removed mailboxes will be deleted from the cache and
  # all newly created mailboxes will be added to the cache.
  # mb           : a Net::IMAP::MailboxList object
  # mailbox      : a Mailbox object
  # server_list  : All mailboxes present on the server
  # client_list  : All mailboxes present on the client
  # server_names : All mailbox names present on the server
  # client_names : All mailbox names present on the client
  def sync

    # Get the server mailboxes list
    server_list = Array.new
    self.connect do |imap|
      imap.list("", "*").each do |mb|
        server_list << mb
      end
    end

    # Get the client mailboxes list
    client_list = Mailbox.all

    # Delete the old mailboxes no longer on server
    server_names = server_list.map{|mb| mb.name}
    client_list.each do |mailbox|
      mailbox.destroy if !server_names.include? mailbox.name
    end

    # Cache the new mailboxes
    client_names = client_list.map{|mailbox| mailbox.name}
    server_list.each do |mb|
      if !client_names.include?(mb.name)
        mailbox = self.mailboxes.new(name: mb.name, delimiter: mb.delim)
        mailbox.flags = mb.attr
        mailbox.save
      end
    end

    return true
  end
end
