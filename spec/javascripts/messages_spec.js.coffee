#= require 'application'

################################
# Helpers
################################

# List of messages
messages_sample = [
  {id: 1, uid: 9, from_address: "user@domain.tld", from_name: null, subject: "Test", internal_date: "2012-05-15T15:09:48Z",  flags: []}
  {id: 2, uid: 10, from_address: "hi@black.com", from_name: "Malcom X", subject: "Test", internal_date: "2012-05-14T15:09:48Z",  flags: ["Seen"]}
  {id: 3, uid: 8, from_address: "kurt@nirvana.com", from_name: "Curt Cobain", subject: "Test", internal_date: "2012-05-13T15:09:48Z",  flags: ["Seen"]}
  {id: 4, uid: 3, from_address: "peace@onearth.org", from_name: "Gandi", subject: "Test", internal_date: "2012-05-10T15:09:48Z",  flags: ["Seen"]}
  {id: 5, uid: 6, from_address: "fhollande@elysee.fr", from_name: "Francoise Hollande", subject: "Test", internal_date: "2012-05-10T15:09:48Z",  flags: ["Seen"]}
  {id: 6, uid: 5, from_address: "chichi@elysee.fr", from_name: "Chichi", subject: "Test", internal_date: "2011-05-09T15:09:48Z",  flags: ["Seen"]}
]

# One message
message_sample = (n) ->
  return messages_sample[n-1]

################################
# Models
################################

# Test the Message model
describe "Webmail.Models.Message", ->

  # Test the message flags
  it "should return boolean for a flag presence", ->
    message = new Webmail.Models.Message(message_sample 4)
    expect(message.flagged?("Seen")).toBe true
    message = new Webmail.Models.Message(message_sample 1)
    expect(message.flagged?("Seen")).toBe false

  # Test the 'from' field name display
  it "should return the from name if exist or a splitted mail address", ->
    message = new Webmail.Models.Message(message_sample 3)
    expect(message.fromName()).toBe "Curt Cobain"
    message = new Webmail.Models.Message(message_sample 1)
    expect(message.fromName()).toBe "user"

  # Test date display
  it "should return a short format of the internal date", ->
    message = new Webmail.Models.Message(message_sample 1)
    expect(message.shortInternalDate()).toBe "15 May"
    message = new Webmail.Models.Message(message_sample 6)
    expect(message.shortInternalDate()).toBe "9 May 2011"

################################
# Collections
################################

# Test the messages collection
describe "Webmail.Collections.Messages", ->

  # Test a collection with no mailbox id
  it "should return an empty mailbox id", ->
    messages = new Webmail.Collections.Messages messages_sample
    expect(messages.mailboxId).toBe null

  # Test a collection with a mailbox id
  it "should return an mailbox id and a correct url", ->
    messages = new Webmail.Collections.Messages messages_sample, mailboxId: 1
    expect(messages.mailboxId).toBe 1
    expect(messages.url()).toBe "/api/mailboxes/1/messages"

  # Test the comparator method
  it "should order the message list by uid", ->
    messages = new Webmail.Collections.Messages messages_sample
    expect(messages.comparator(messages.get(1), messages.get(5))).toBe -1
    expect(messages.comparator(messages.get(6), messages.get(2))).toBe 1

################################
# Views
################################

# Test the messages index view
describe "Webmail.Views.MessagesIndex", ->

  # Test the messages list whith no messages
  # should print an empty table
  it "should print an empty list", ->
    view = new Webmail.Views.MessagesIndex()
    view.render()
    expect(view.$el).toBe "table"

  # Test the messages list
  it "should print the inbox list", ->
    # Import a collection of inboxes
    messages = new Webmail.Collections.Messages messages_sample
    view = new Webmail.Views.MessagesIndex collection: messages
    view.render()
    expect(view.$el).toBe "table"
    expect(view.$el).toContain "tr"
    expect(view.$el).toHaveText /user@domain.tld/
    expect(view.$el).toHaveText /kurt@nirvana.com/

  # Test the messages order
  # They should be ordered by uid
  it "should be sorted by uid", ->
    messages = new Webmail.Collections.Messages messages_sample
    view = new Webmail.Views.MessagesIndex collection: messages
    view.render()
    messages = _.map view.$el.children("tbody").children("tr"), (tr) ->
      $(tr)
    expect(messages[5]).toHaveText /peace@onearth.org/
    expect(messages[4]).toHaveText /chichi@elysee.fr/
    expect(messages[3]).toHaveText /fhollande@elysee.fr/
    expect(messages[2]).toHaveText /kurt@nirvana.com/
    expect(messages[1]).toHaveText /user@domain.tld/
    expect(messages[0]).toHaveText /hi@black.com/

  # Test child view update on collection change
  it "should update child model", ->
    messagesCollection = new Webmail.Collections.Messages messages_sample
    view = new Webmail.Views.MessagesIndex collection: messagesCollection
    view.render()
    messages = _.map view.$el.children("tbody").children("tr"), (tr) ->
      $(tr)
    expect(messages[0].hasClass('new')).toBe false
    expect(messages[1].hasClass('new')).toBe true
    message = messagesCollection.get 1
    message.set "flags", ["Seen"]
    messages = _.map view.$el.children("tbody").children("tr"), (tr) ->
      $(tr)
    expect(messages[1].hasClass('new')).toBe false

# Test message show view
describe "Webmail.Views.MessagesShow", ->

  # Test the displaying of a single message
  it "should display the view of an individual message", ->
    messages = new Webmail.Collections.Messages messages_sample
    message = messages.get(3)
    message.set 'body', 'Hello there'
    view = new Webmail.Views.MessagesShow model: message
    view.render()
    expect(view.$el).toBe "div"
    expect(view.$el).toHaveText /Hello there/
    expect(view.$el).toHaveText /Curt Cobain/
    expect(view.$el).toHaveText /kurt@nirvana.com/
    expect(view.$el).toHaveText /Test/

# Test message item view
describe "Webmail.Views.MessagesItem", ->

  # should render a single message with its associed class
  it "should render a single message with its associed class", ->
    message = new Webmail.Models.Message(message_sample 1)
    messageView = new Webmail.Views.MessagesItem
      model: message
    messageView.render()
    expect(messageView.$el).toBe "tr"
    expect(messageView.$el.hasClass('message')).toBe true
    expect(messageView.$el.hasClass('new')).toBe true

    message = new Webmail.Models.Message(message_sample 2)
    messageView = new Webmail.Views.MessagesItem
      model: message
    messageView.render()
    expect(messageView.$el).toBe "tr"
    expect(messageView.$el.hasClass('message')).toBe true
    expect(messageView.$el.hasClass('new')).toBe false