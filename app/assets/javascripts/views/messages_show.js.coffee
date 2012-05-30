Webmail.Views.MessagesShow = Backbone.View.extend

  render: ->
    this.$el.html JST['messages/show']
      message: this.model
    return this