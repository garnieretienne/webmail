Webmail.Views.MessagesShow = Backbone.View.extend

  initialize: ->
    # Declare bind events
    _.bindAll(this, 'render')
    this.model.bind 'change', this.render # re-render the message when it change (body loaded)

  render: ->
    this.$el.html JST['messages/show']
      message: this.model
    return this