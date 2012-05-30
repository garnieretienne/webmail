class ApplicationController < ActionController::Base
  protect_from_forgery

  # Helper to return the current authenticated account
  def current_account
    if session[:account_id]
      account = Account.find(session[:account_id]) if session[:account_id]
      account.password = session[:password]
      return account
    else
      return false
    end
  end
  helper_method :current_account

  # Filter to manage authorization
  #   before_filter :authenticate
  def authenticate
    redirect_to login_path, alert: "You must be authenticated" if !current_account
  end

  # Filter to manage authorization on api
  # Return a 403 error if not authenticated
  #   before_filter :authorized?
  def authorized?
    render nothing: true, status: :forbidden if !current_account
  end
end
