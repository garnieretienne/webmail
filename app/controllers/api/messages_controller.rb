class Api::MessagesController < ApplicationController

  respond_to :json
  before_filter :authorized?

  def index
    @mailbox = current_account.mailboxes.find(params[:mailbox_id])
    respond_with(@messages = @mailbox.messages.order("uid DESC").limit(50))
  end

  def show
    @mailbox = current_account.mailboxes.find(params[:mailbox_id])
    @message = @mailbox.messages.find(params[:id])
    @account = current_account
    imap = @account.connect
    @message.get_body! imap
    imap.logout
    respond_with(@message)
  end
end
