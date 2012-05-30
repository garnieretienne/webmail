window.Webmail =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: (data) -> 
    mailboxes = new Webmail.Collections.Mailboxes(data.mailboxes)
    messages  = new Webmail.Collections.Messages(data.messages, mailboxId: data.mailbox_id)
    new Webmail.Routers.App
      mailboxes: mailboxes
      messages: messages
    Backbone.history.start()
