# Manage Account
class AccountsController < ApplicationController
  # user must be authenticated
  before_filter :authenticate

  # Authenticated user can acces his mailboxes using this view
  # Init the backbone app
  def show
    @mailboxes = current_account.mailboxes
    @inbox = current_account.mailboxes.find_by_name("INBOX")
    @messages = @inbox.messages.order("uid DESC").limit(50) if @inbox
  end

  # Synchronize all mailboxes and messages with the server
  def sync
    @account = current_account
    @account.connect do |imap|
      @account.sync imap
    end
    render nothing: true
  end
end
