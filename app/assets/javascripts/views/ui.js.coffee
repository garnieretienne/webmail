Webmail.Views.UI = Backbone.View.extend

  events:
    "click #synchronize": "syncAccount"

  render: ->
    this.renderModals()
    this.renderControls()
    return this

  # Display account controls elements
  renderControls: ->
    this.$el.append JST['ui/controls']

  # Display various hidden modals
  renderModals: ->
    this.$el.append JST['ui/modals']

  # Synchronize the account (mailboxes and messages)
  syncAccount: (e) ->
    e.preventDefault()
    $(e.currentTarget).button('loading')
    $('#sync-modal').modal
      'backdrop': 'static'
    $.ajax
      url: "/api/sync",
      success: ->
        $(e.currentTarget).button('reset')
        $('#sync-modal').modal('hide')