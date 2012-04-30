# Manage Account
class AccountsController < ApplicationController
  # user must be authenticated
  before_filter :authenticate

  # Authenticated user can acces his inboxes using this view
  # Init the backbone app
  def show
  end
end
