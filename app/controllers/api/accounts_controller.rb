class Api::AccountsController < ApplicationController
  # user must be authenticated
  before_filter :authorized?

  # Synchronize all mailboxes and messages with the server
  def sync
    @account = current_account
    @account.connect do |imap|
      @account.sync imap
    end
    render nothing: true
  end
end
