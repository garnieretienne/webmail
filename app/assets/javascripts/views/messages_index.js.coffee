Webmail.Views.MessagesIndex = Backbone.View.extend
  tagName: "table"
  className: "table table-condensed table-striped"

  events:
    "click .message": "showMessage"

  initialize: ->
    # If no data are loaded
    this.collection = new Webmail.Collections.Messages() if !this.collection
    
    # Declare bind events
    _.bindAll(this, 'render')
    _.bindAll(this, 'renderChild')
    _.bindAll(this, 'updateChild')
    this.collection.bind 'change:flags', this.updateChild

  # Display the selected message
  showMessage: (e) ->
    id = $(e.currentTarget).attr("data-id")
    this.collection.get(id).display()

  # Render message item view for each messages from the collection
  render: ->
    self = this
    this.$el.html JST['messages/index']
    this.collection.each (message) ->
      self.renderChild message
    return this

  # Render a specific messages
  renderChild: (message) ->
    messageView = new Webmail.Views.MessagesItem
      model: message
    $(this.$el).append(messageView.render().$el)

  # Re-render an updated message item view
  updateChild: (message) ->
    messageView = new Webmail.Views.MessagesItem
      model: message
    $(this.$el).children("tbody").children("[data-id=#{message.id}]").replaceWith(messageView.render().$el)