Webmail.Routers.App = Backbone.Router.extend
  initialize: (data) ->
    this.mailboxes = data.mailboxes
    this.messages  = data.messages

    # Display UI elements like synchronize button
    this.displayUI()

  routes:
    "": "index"
    "mailboxes/:id": "show"
    "mailboxes/:mailboxId/messages/:id": "showMessage"

  # Display UI elements like account's actions buttons
  # or modals contents
  displayUI: ->
    UIView = new Webmail.Views.UI()
    $('#controls').html UIView.render().$el

  # Show the inbox view with populated data
  index: ->
    mailboxesView = new Webmail.Views.MailboxesIndex
      collection: this.mailboxes
      currentMailbox: this.messages.mailboxId
    messagesView  = new Webmail.Views.MessagesIndex
      collection: this.messages
    $('#mailboxes').html mailboxesView.render().$el
    $('#messages').html messagesView.render().$el

  # Show the content of a specific mailbox
  show: (id) ->

    # Check if mailboxes are already displayed (navigation),
    # if not (direct access), render them.
    if $('#mailboxes').html() == ""
      mailboxesView = new Webmail.Views.MailboxesIndex
        collection: this.mailboxes
        currentMailbox: id
      $('#mailboxes').html mailboxesView.render().$el

    # Fetch all messages from the mailbox
    # and render the index view
    this.messages = new Webmail.Collections.Messages({}, mailboxId: id)
    messagesView  = new Webmail.Views.MessagesIndex
      collection: this.messages
    this.messages.fetch
      success: ->
        $('#messages').html messagesView.render().$el

  # Display a message
  showMessage: (mailboxId, id) ->
    # Accessors
    messages = this.messages
    message = null

    # Check if mailboxes are already displayed (navigation),
    # if not (direct access), render them.
    if $('#mailboxes').html() == ""
      mailboxesView = new Webmail.Views.MailboxesIndex
        collection: this.mailboxes
        currentMailbox: mailboxId
      $('#mailboxes').html mailboxesView.render().$el

    # Fetch all messages from this messages collection is not already loaded
    if parseInt(messages.mailboxId) != parseInt(mailboxId)
      messages = new Webmail.Collections.Messages({}, mailboxId: mailboxId)
      messages.fetch
        success: ->
          message = messages.get(id)

          # Display the message
          messageView = new Webmail.Views.MessagesShow
            model: message
          $('#messages').html messageView.render().$el
          message.fetch()
    
    # If messages collection is already loaded, display the message
    else
      message = messages.get(id)

      # Display the message
      messageView = new Webmail.Views.MessagesShow
        model: message
      $('#messages').html messageView.render().$el
      message.fetch()