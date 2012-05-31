Webmail.Routers.App = Backbone.Router.extend
  initialize: (data) ->
    this.mailboxes = data.mailboxes
    this.messages  = data.messages

  routes:
    "": "index"
    "mailboxes/:id": "show"
    "mailboxes/:mailboxId/messages/:id": "showMessage"

  # Show the inbox view with populated data
  index: ->
    mailboxesView = new Webmail.Views.MailboxesIndex
      collection: this.mailboxes
    messagesView  = new Webmail.Views.MessagesIndex
      collection: this.messages
    $('#mailboxes').html mailboxesView.render().$el
    $('#messages').html messagesView.render().$el

  # Show the content of a specific mailbox
  show: (id) ->
    this.messages = new Webmail.Collections.Messages({}, mailboxId: id)
    mailboxesView = new Webmail.Views.MailboxesIndex
      collection: this.mailboxes
    messagesView  = new Webmail.Views.MessagesIndex
      collection: this.messages
    this.messages.fetch
      success: ->
        $('#mailboxes').html mailboxesView.render().$el
        $('#messages').html messagesView.render().$el

  # Display a message
  showMessage: (mailboxId, id) ->

    # Check if mailboxes are already displayed (navigation),
    # if not (direct access), render them.
    if $('#mailboxes').html() == ""
      mailboxesView = new Webmail.Views.MailboxesIndex
        collection: this.mailboxes
      $('#mailboxes').html mailboxesView.render().$el

    # Fetch all messages from the mailboxes if not already fetched
    messages = new Webmail.Collections.Messages({}, mailboxId: mailboxId)
    messages.fetch
      success: ->
        message = messages.get(id)

        # Display the message
        messageView = new Webmail.Views.MessagesShow
          model: message
        message.fetch
          success: ->
            $('#messages').html messageView.render().$el