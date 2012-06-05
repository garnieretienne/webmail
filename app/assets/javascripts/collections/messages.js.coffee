Webmail.Collections.Messages = Backbone.Collection.extend
  model: Webmail.Models.Message

  # Initialize
  initialize: (models, options) ->
    options || (options = {});
    this.mailboxId = options.mailboxId || null

  # Build the messages collection URL
  # Use the mailbox id (RESTFUL)
  url: ->
    return "/api/mailboxes/#{this.mailboxId}/messages"

  # Sort the messages by UID
  comparator: (message1, message2) ->
    if message1.get('uid') > message2.get('uid')
      return -1
    else
      return +1