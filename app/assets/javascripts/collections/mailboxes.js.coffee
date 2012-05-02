Webmail.Collections.Mailboxes = Backbone.Collection.extend
  model: Webmail.Models.Mailbox
  url: '/api/mailboxes'

  # Sort the mailboxes per alphabetic order
  # ALWAYS puts INBOX special mailbox on the top
  comparator: (mailbox) ->
    if mailbox.get('name') == 'INBOX'
      return 0
    else
      return mailbox.get "name"