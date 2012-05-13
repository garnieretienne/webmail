Webmail.Views.MessagesIndex = Backbone.View.extend
  tagName: "table"
  className: "table table-condensed table-striped"

  render: ->
    this.$el.html JST['messages/index']
      messages: this.collection
    return this