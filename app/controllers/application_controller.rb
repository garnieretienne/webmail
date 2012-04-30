class ApplicationController < ActionController::Base
  protect_from_forgery

  # Helper to return the current authenticated account
  def current_account
    Account.find(session[:account_id]) if session[:account_id]
  end
  helper_method :current_account

  # Filter to manage authorization
  #   before_filter :authenticate
  def authenticate
    redirect_to login_path, alert: "You must be authenticated" if !current_account
  end
end
end
