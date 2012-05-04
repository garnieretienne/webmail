#= require 'application'

# List of mailboxes
mailboxes_sample = [
  {id: 1, name: "INBOX", flags: ["Hasnochild"], delimiter: "/"}
  {id: 2, name: "Sent", flags: ["Hasnochild"], delimiter: "/"}
  {id: 3, name: "Hidden", flags: ["Hasnochild", "Noselect"], delimiter: "/"}
  {id: 4, name: "Parent", flags: ["Haschild", "Noselect"], delimiter: "/"}
  {id: 5, name: "Gimap ERROR", flags: ["Haschild", "Hasnochild"], delimiter: "/"}
  {id: 6, name: "Simple", flags: ["Hasnochild"], delimiter: "/"}
  {id: 7, name: "Parent/Child", flags: [], delimiter: "/"}
]

# One mailbox
mailbox_sample = (n) ->
  return mailboxes_sample[n-1]


# Test the mailboxes index view
describe "Webmail.Views.MailboxesIndex", ->

  # Test the mailboxes list whith no mailboxes
  it "should print an empty list", ->
    view = new Webmail.Views.MailboxesIndex()
    view.render()
    expect(view.$el).toBe "ul"
    expect(view.$el).toBeNull

  # Test the mailboxes list
  it "should print the inbox list", ->
    # Import a collection of inboxes
    mailboxes = new Webmail.Collections.Mailboxes mailboxes_sample
    view = new Webmail.Views.MailboxesIndex collection: mailboxes
    view.render()
    expect(view.$el).toBe "ul" 
    expect(view.$el).toContain "li" 
    expect(view.$el).toHaveText /INBOX/ 
    expect(view.$el).toHaveText /Sent/

  # Test the mailbox alphabetical order
  # INBOX should always be on top
  it "should be sorted alphabetically", ->
    mailboxes = new Webmail.Collections.Mailboxes mailboxes_sample
    view = new Webmail.Views.MailboxesIndex collection: mailboxes
    view.render()
    mailboxes = _.map view.$el.children("li"), (li) ->
      $(li).text()
    expect(mailboxes[0]).toBe('INBOX')
    expect(mailboxes[1]).toBe('Gimap ERROR')
    expect(mailboxes[2]).toBe('Hidden')
    expect(mailboxes[3]).toBe('Parent')
    expect(mailboxes[4]).toBe('Parent/Child')
    expect(mailboxes[5]).toBe('Sent')
    expect(mailboxes[6]).toBe('Simple')


# Test the mailbox model
describe "Webmail.Models.Mailbox", ->

  it "should return boolean for a flag presence", ->
    mailbox = new Webmail.Models.Mailbox(mailbox_sample 1)
    expect(mailbox.flagged?("Hasnochild")).toBe true

  # Test if a mailbox has childs
  # hasChild -> HasChild
  it "should test if a mailbox has childs", ->
    mailbox = new Webmail.Models.Mailbox(mailbox_sample 1)
    expect(mailbox.hasChild?()).toBe false 
    mailbox = new Webmail.Models.Mailbox(mailbox_sample 4)
    expect(mailbox.hasChild?()).toBe true
    mailbox = new Webmail.Models.Mailbox(mailbox_sample 5)
    expect(mailbox.hasChild?()).toBe false
    mailbox = new Webmail.Models.Mailbox(mailbox_sample 6)
    expect(mailbox.hasChild?()).toBe false

  # Test if a mailbox is selectable
  # selectable -> ! NoSelect
  it "should test if a mailbox is selectable", ->
    mailbox = new Webmail.Models.Mailbox(mailbox_sample 1)
    expect(mailbox.selectable?()).toBe(true)
    mailbox = new Webmail.Models.Mailbox(mailbox_sample 4)
    expect(mailbox.selectable?()).toBe(false)

# Test the mailbox collection
describe "Webmail.Collections.Mailboxes", ->

  # Test the conparator method, should be alphabetical
  # -1: mailbox1 on top of mailbox2
  # 1 : mailbox2 on top of mailbox1
  it "should compare two mailbox and return an index for alphabetical order", ->
    mailboxes = new Webmail.Collections.Mailboxes mailboxes_sample
    # IMAP : Simple => IMAP on top of Simple
    expect(mailboxes.comparator(mailboxes.get(1), mailboxes.get(6))).toBe(-1)
    # Simple : IMAP => IMAP on top of Simple
    expect(mailboxes.comparator(mailboxes.get(6), mailboxes.get(1))).toBe(1)
    # Parent/Child : Parent => Parent on top of Parent/Child
    expect(mailboxes.comparator(mailboxes.get(7), mailboxes.get(4))).toBe(1)
