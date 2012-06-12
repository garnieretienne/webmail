Webmail.Views.MessagesItem = Backbone.View.extend
  tagName: "tr"

  # Declare bind events
  initialize: ->
    _.bindAll(this, 'render')

  # Define html class for this message
  # new: this message is marked as unread
  classAttr: -> 
    htmlClass = 'message'
    message = this.model
    if !message.flagged? 'Seen'
      htmlClass += " new"
    return htmlClass

  # Render individual message
  # Take care of class and custom attribute (data-*)
  render: ->
    message = this.model
    this.$el.attr('class', this.classAttr()).attr('data-id', message.id).html JST['messages/item']
      message: this.model
    return this