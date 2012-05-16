class Api::MessagesController < ApplicationController

  respond_to :json
  before_filter :authorized?

  def index
    @mailbox = current_account.mailboxes.find(params[:mailbox_id])
    respond_with(@messages = @mailbox.messages.order("uid DESC").limit(50))
  end
end
