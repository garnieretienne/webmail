Webmail.Views.MailboxesItem = Backbone.View.extend
  tagName: "li"

  # Declare bind events
  initialize: ->
    _.bindAll(this, 'render')

  # Define html class for this mailbox
  # child: this mailbox has a parent
  # selected: this mailbox has been selected by the user
  classAttr: -> 
    htmlClass = 'mailbox'
    mailbox = this.model
    if mailbox.hasParent?()
      htmlClass += " child"
    if mailbox.get('selected')
      htmlClass += " selected"
    return htmlClass

  # Render individual mailbox
  # Take care of class and custom attribute (data-*)
  render: ->
    mailbox = this.model
    this.$el.attr('class', this.classAttr()).attr('data-id', mailbox.id).html JST['mailboxes/item']
      mailbox: this.model
    return this