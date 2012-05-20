# Manage Authentication
class SessionsController < ApplicationController

  # Login page
  def new
    @account = Account.new
  end

  # Login
  # This action authenticate an existing Account 
  # OR create and authenticate a new Account (if the given credentials are correct)
  #
  #   ... Erase old alerts ...
  #   ... Search if this account exist or if account must be created ...
  #   @account = Account.find_by_email_address(params[:email_address])
  #   if @account
  #     ... account with this email address exist ...
  #     ... validate the password (must not be null or "") ...
  #     ... try to authenticate the account on the IMAP server using the credentials given by the user
  #     if @account.authenticate
  #       ... credential are validated by the IMAP server ...
  #       ... authenticate the account ...
  #       ... alert the user ...
  #     else
  #       ... something goes wrong (IMAP server unreachable, or he refuse the connection, or the given password was wrong) ...
  #       ... alert the user ...
  #     end
  #   else
  #     ... this is a new email address, account must be created ...
  #     ... validate the account (email and password) ...
  #     ... try to find a corresponding provider for the given email address ...
  #     provider = Provider.find_for params[:email_address]
  #     if provider
  #       ... a corresponding provider has been found ...
  #       ... try to authenticate the account on the provider using his credentials
  #       if @account.authenticate
  #         ... credential are validated by the IMAP server, the account can be created and authentified ...
  #         ... create the account ...
  #         ... authenticate the account ...
  #         ... alert the user ...
  #       else
  #         ... something goes wrong (IMAP server unreachable, or he refuse the connection, or the given password was wrong) ...
  #         ... alert the user ...
  #       end
  #     else
  #       ... the provider for this email is not yet supported ...
  #       ... alert the user ...
  #     end
  #   end
  #   ... redirect the user in the emails reader page ...
  def create
    # Erase old alerts
    flash.discard

    # Search if this account exist or if account must be created
    @account = Account.find_by_email_address(params[:email_address])
    if @account
      @account.password = params[:password]

      # Test the submitted attributes for validations errors on the model
      # specialy the password in this case (must not be blank or "")
      if !@account.valid?
        render action: 'new' and return
      end

      # Try to authenticate the account with the given credentials
      if @account.authenticate

        # The account credentials are right, authenticate it
        flash.notice = "You successfully authenticated on '#{@account.provider.name}' as '#{@account.email_address}'."
        session[:account_id] = @account.id

        # TODO: encrypt password
        session[:password] = @account.password
      else

        # Redirect to the login page with an error message 
        # (cannot authenticated on the service provider IMAP server, server down, refuse connection for this account or wrong password)
        flash.alert = "The server is down or refuse the connection."
        render action: 'new' and return
      end
    else

      # Test the submitted attributes for validations errors on the model
      @account = Account.new(email_address: params[:email_address], provider: Provider.first)
      @account.password = params[:password]
      if !@account.valid?
        render action: 'new' and return
      end

      # Try to find the service provider for this email
      provider = Provider.find_for params[:email_address]
      if provider

        # Try to authenticate the account on this provider
        @account = Account.new(email_address: params[:email_address], provider: provider)
        @account.password = params[:password]
        if @account.authenticate

          # The account credentials are right, save and authenticate it
          @account.save
          flash.notice = "You successfully authenticated on '#{@account.provider.name}' as '#{@account.email_address}'."
          session[:account_id] = @account.id

          # TODO: encrypt password
          session[:password] = @account.password
        else

          # Redirect to the login page with an error message 
          # (cannot authenticated on the service provider IMAP server, server down, refuse connection for this account or wrong password)
          flash.alert = "The server is down or refuse the connection."
          render action: 'new' and return
        end
      else

        # Redirect to the login page with an error message (service provider not yet supported)
        @account = Account.new
        flash.alert = "The email service provider for '#{params[:email_address]}' is not supported yet."
        render action: 'new' and return
      end
    end

    # Redirect the user to his account page
    redirect_to mail_path
  end

  # Logout
  def destroy
    session[:account_id] = nil
    flash.notice = "You've been disconnected."
    redirect_to root_path
  end
end
