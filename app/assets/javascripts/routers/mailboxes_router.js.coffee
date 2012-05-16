Webmail.Routers.Mailboxes = Backbone.Router.extend
  initialize: (data) ->
    this.mailboxes = data.mailboxes
    this.messages  = data.messages

  routes:
    "": "index"
    "mailboxes/:id": "show"

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