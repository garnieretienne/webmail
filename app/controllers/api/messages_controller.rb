class Api::MessagesController < ApplicationController

  respond_to :json
  before_filter :authorized?

  def index
    @mailbox = current_account.mailboxes.find(params[:id])
    respond_with(@messages = @mailbox.messages.all)
  end
end
