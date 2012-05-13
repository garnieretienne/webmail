window.Webmail =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: (data) -> 
    mailboxes = new Webmail.Collections.Mailboxes(data.mailboxes);
    messages  = new Webmail.Collections.Messages(data.messages)
    new Webmail.Routers.Mailboxes
      mailboxes: mailboxes
      messages: messages
    Backbone.history.start()
