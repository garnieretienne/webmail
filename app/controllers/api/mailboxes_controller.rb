class Api::MailboxesController < ApplicationController

  respond_to :json
  before_filter :authorized?

  def index
    respond_with(@mailboxes = current_account.mailboxes.all)
  end

end
