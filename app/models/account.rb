# This class is an Active Record object to store accounts credentials on an email service provider.
# It store an email address and a password, used to connect on the user's IMAP account.
# Only the email address is stored in database, the password is a virtual attribute and is 
# only used to initiate the IMAP connection.
class Account < ActiveRecord::Base
  attr_accessible :email_address, :provider

  # Virtual attribute: password
  attr_accessor :password

  # An Account belong to one Provider
  belongs_to :provider

  # The email address and the provider must be specified
  validates :email_address, :provider_id, presence: true

  # The email address must be unique and in a good format (user@domain.tld)
  validates :email_address, uniqueness: true, email_format: true

  # Authenticate an user using his IMAP credentials.
  # Authentication use the 'LOGIN' command to authenticate on the IMAP server.
  # see: http://ruby-doc.org/stdlib-1.9.3/libdoc/net/imap/rdoc/Net/IMAP.html#method-i-login
  # On failed authentication, do not show an error but return false.
  # On successfull authentication, return true and set the session variable 'account'.
  def authenticate
  	connection = self.provider.connect
  	if connection
  	  begin
  	    connection.login(self.email_address, self.password)
  	    connection.logout
  	    return true
  	  rescue Net::IMAP::NoResponseError	
  	    return false
      end
    end
    return false
  end
end
