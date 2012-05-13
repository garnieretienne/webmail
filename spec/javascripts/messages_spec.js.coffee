#= require 'application'

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

# Test the Message model
describe "Webmail.Models.Message", ->

  it "should return boolean for a flag presence", ->
    message = new Webmail.Models.Message(message_sample 4)
    expect(message.flagged?("Seen")).toBe true
    message = new Webmail.Models.Message(message_sample 1)
    expect(message.flagged?("Seen")).toBe false

  it "should return the from name if exist or a splitted mail address", ->
    message = new Webmail.Models.Message(message_sample 3)
    expect(message.fromName()).toBe "Curt Cobain"
    message = new Webmail.Models.Message(message_sample 1)
    expect(message.fromName()).toBe "user"

  it "should return a short format of the internal date", ->
    message = new Webmail.Models.Message(message_sample 1)
    expect(message.shortInternalDate()).toBe "15 May"
    message = new Webmail.Models.Message(message_sample 6)
    expect(message.shortInternalDate()).toBe "9 May 2011"