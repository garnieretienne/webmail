# Manage Account
class AccountsController < ApplicationController
  # user must be authenticated
  before_filter :authenticate

  # Authenticated user can acces his inboxes using this view
  # Init the backbone app
  def show
    @mailboxes = current_account.mailboxes
    @messages = current_account.mailboxes.find_by_name("INBOX").messages.order("uid DESC").limit(50)
  end
end
