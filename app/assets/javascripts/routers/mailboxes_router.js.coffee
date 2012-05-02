Webmail.Routers.Mailboxes = Backbone.Router.extend
  initialize: (data) ->
    this.mailboxes = data.mailboxes

  routes:
    "": "index"

  index: ->
    view = new Webmail.Views.MailboxesIndex
      collection: this.mailboxes
    $('#mailboxes').html view.render().$el