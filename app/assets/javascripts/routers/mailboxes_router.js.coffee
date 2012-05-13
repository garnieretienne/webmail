Webmail.Routers.Mailboxes = Backbone.Router.extend
  initialize: (data) ->
    this.mailboxes = data.mailboxes
    this.messages  = data.messages

  routes:
    "": "index"

  index: ->
    mailboxesView = new Webmail.Views.MailboxesIndex
      collection: this.mailboxes
    messagesView  = new Webmail.Views.MessagesIndex
      collection: this.messages
    $('#mailboxes').html mailboxesView.render().$el
    $('#messages').html messagesView.render().$el