Webmail.Views.MessagesIndex = Backbone.View.extend
  tagName: "table"
  className: "table table-condensed table-striped"

  events:
    "click .message": "show_message"

  # Display the selected message
  show_message: (e) ->
    id = $(e.currentTarget).attr("data-id")
    this.collection.get(id).display()

  render: ->
    this.$el.html JST['messages/index']
      messages: this.collection
    return this