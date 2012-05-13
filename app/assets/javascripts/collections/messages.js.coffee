Webmail.Collections.Messages = Backbone.Collection.extend
  model: Webmail.Models.Message
  url: '/api/messages'

  # Sort the messages by UID
  comparator: (message1, message2) ->
    if message1.get('uid') > message2.get('uid')
      return -1
    else
      return +1