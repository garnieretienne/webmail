Webmail.Views.MailboxesIndex = Backbone.View.extend
  tagName: "ul"

  events:
    "click .mailbox": "selectMailbox"

  initialize: ->
    # If no data are loaded
    this.collection = new Webmail.Collections.Mailboxes() if !this.collection
    
    # Declare bind events
    _.bindAll(this, 'render')
    _.bindAll(this, 'renderChild')
    _.bindAll(this, 'updateChild')
    this.collection.bind 'change', this.updateChild

  # Render mailbox item view for all mailbox from the collection
  render: ->
    self = this
    this.collection.each (mailbox) ->
      # Render the mailbox view
      self.renderChild mailbox
      # Update the view if this mailbox is the current selected mailbox
      if mailbox.id == parseInt(self.options.currentMailbox)
        mailbox.select()
    return this

  # Render a specific mailbox
  renderChild: (mailbox) ->
    mailboxView = new Webmail.Views.MailboxesItem
      model: mailbox
    $(this.$el).append(mailboxView.render().$el)

  # Re-render an updated mailbox
  updateChild: (mailbox) ->
    mailboxView = new Webmail.Views.MailboxesItem
      model: mailbox
    $(this.$el).children("[data-id=#{mailbox.id}]").replaceWith(mailboxView.render().$el)

  # Display the specified mailbox content
  selectMailbox: (e) ->
    e.preventDefault()
    id = $(e.currentTarget).attr("data-id")
    mailbox = this.collection.get(id)

    # Set the mailbox as selected and
    # display it content
    mailbox.select()
    mailbox.display()

