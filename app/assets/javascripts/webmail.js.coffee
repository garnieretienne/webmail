window.Webmail =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  init: (data) -> 
    mailboxes = new Webmail.Collections.Mailboxes(data.mailboxes);
    new Webmail.Routers.Mailboxes
      mailboxes: mailboxes
    Backbone.history.start()
