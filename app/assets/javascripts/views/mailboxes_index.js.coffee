Webmail.Views.MailboxesIndex = Backbone.View.extend
  tagName: "ul"

  render: ->
    this.$el.html JST['mailboxes/index']
      mailboxes: this.collection
    return this

