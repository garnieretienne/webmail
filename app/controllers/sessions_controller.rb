# Manage Authentication
class SessionsController < ApplicationController

  # Login page
  def new
  end

  # Login
  def create

    # TODO: test the account (validation errors)
    
    # Search if this account exist or if account must be created
    account = Account.find_by_email_address(params[:email_address])
    if account
      # Try to authenticate the account with the given credentials
      account.password = params[:password]
      if account.authenticate
        # The account credentials are right, authenticate it
        session[:account] = account
      else
        # TODO: redirect to the login page with an error message 
        # (cannot authenticated on the service provider IMAP server, server down, refuse connection for this account or wrong password)
      end
    else
      # Try to find the service provider for this email
      provider = Provider.find_for params[:email_address]
      if provider
        # Try to authenticate the account on this provider
        account = Account.new(email_address: params[:email_address], provider: provider)
        account.password = params[:password]
        if account.authenticate
          # The account credentials are right, save and authenticate it
          account.save
          session[:account] = account
        else
          # TODO: redirect to the login page with an error message 
          # (cannot authenticated on the service provider IMAP server, server down, refuse connection for this account or wrong password)
        end
      else
        # TODO: redirect to the login page with an error message (service provider not yet supported)
      end
    end

    redirect_to root_path # TODO: remove this redirection
  end

  # Logout
  def destroy
  end
end
