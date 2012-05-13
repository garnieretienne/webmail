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
  has_many :mailboxes, dependent: :destroy

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

  # Sync all mailboxes and messages from the IMAP server.
  # All removed mailboxes will be deleted from the cache and
  # all newly created mailboxes will be added to the cache.
  def sync

    # Sync mailboxes
    self.sync_mailboxes
    self.reload

    # Sync messages
    self.mailboxes.each do |mailbox|
      next if mailbox.flagged? :Noselect
      mailbox.sync self.password
    end
  end

  # Sync the mailbox list
  def sync_mailboxes
    self.reload

    # Get the server mailboxes list and
    # build a map of flags
    mailboxes = Array.new
    self.connect do |imap|
      imap.list("", "*").each do |mailbox_data|
        mailboxes << mailbox_data
      end
    end
    mailboxes_flags = Hash.new
    mailboxes.each do |mailbox_data|
      mailboxes_flags[mailbox_data.name] = mailbox_data.attr
    end

    # Get the cached mailboxes and
    # build map of flags
    cached_mailboxes = self.mailboxes
    cached_mailboxes_flags = Hash.new
    cached_mailboxes.each do |mailbox|
      cached_mailboxes_flags[mailbox.name] = mailbox.flags
    end

    # Cache the new mailboxes, update mailboxes flags and
    # delete non longer existing mailboxes from the cache
    mailboxes.each do |mailbox_data|
      if !cached_mailboxes_flags[mailbox_data.name]
        mailbox = self.mailboxes.new(name_utf7: mailbox_data.name, delimiter: mailbox_data.delim)
        mailbox.flags = mailbox_data.attr
        mailbox.save
      end
    end

    # Delete old mailboxes and update flags
    cached_mailboxes_flags.each do |name, flags|
      if !mailboxes_flags[name]
        mailbox = self.mailboxes.find_by_name(name)
        mailbox.destroy
      elsif mailboxes_flags[name] != flags
        mailbox = self.mailboxes.find_by_name(name)
        mailbox.flags = flags
        mailbox.save
      end
    end
  end
end
