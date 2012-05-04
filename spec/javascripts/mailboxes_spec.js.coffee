#= require 'application'

# List of mailboxes
mailboxes_sample = [
  {id: 1, name: "INBOX", flags: ["Hasnochildren"], delimiter: "/"}
  {id: 2, name: "Sent", flags: ["Hasnochildren"], delimiter: "/"}
  {id: 3, name: "Hidden", flags: ["Hasnochildren", "Noselect"], delimiter: "/"}
  {id: 4, name: "Parent", flags: ["Haschildren", "Noselect"], delimiter: "/"}
  {id: 5, name: "Gimap ERROR", flags: ["Haschildren", "Hasnochildren"], delimiter: "/"}
  {id: 6, name: "Simple", flags: ["Hasnochildren"], delimiter: "/"}
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
      $(li)
    expect(mailboxes[0]).toHaveText /INBOX/
    expect(mailboxes[1]).toHaveText /Gimap ERROR/
    expect(mailboxes[2]).toHaveText /Hidden/
    expect(mailboxes[3]).toHaveText /Parent/
    expect(mailboxes[4]).toHaveText /Child/
    expect(mailboxes[5]).toHaveText /Sent/
    expect(mailboxes[6]).toHaveText /Simple/


# Test the mailbox model
describe "Webmail.Models.Mailbox", ->

  it "should return boolean for a flag presence", ->
    mailbox = new Webmail.Models.Mailbox(mailbox_sample 1)
    expect(mailbox.flagged?("Hasnochildren")).toBe true

  # Test if a mailbox has childs
  # hasChild -> HasChild
  it "should test if a mailbox has childs", ->
    mailbox = new Webmail.Models.Mailbox(mailbox_sample 1)
    expect(mailbox.hasChildren?()).toBe false 
    mailbox = new Webmail.Models.Mailbox(mailbox_sample 4)
    expect(mailbox.hasChildren?()).toBe true
    mailbox = new Webmail.Models.Mailbox(mailbox_sample 5)
    expect(mailbox.hasChildren?()).toBe false
    mailbox = new Webmail.Models.Mailbox(mailbox_sample 6)
    expect(mailbox.hasChildren?()).toBe false
    mailbox = new Webmail.Models.Mailbox(mailbox_sample 7)
    expect(mailbox.hasChildren?()).toBe false

  # Test if a mailbox is selectable
  # selectable -> ! NoSelect
  it "should test if a mailbox is selectable", ->
    mailbox = new Webmail.Models.Mailbox(mailbox_sample 1)
    expect(mailbox.selectable?()).toBe(true)
    mailbox = new Webmail.Models.Mailbox(mailbox_sample 4)
    expect(mailbox.selectable?()).toBe(false)

  # Test if a mailbox has Parent
  it "should detect if a mailbox has a parent", ->
    mailbox = new Webmail.Models.Mailbox(mailbox_sample 1)
    expect(mailbox.hasParent?()).toBe(false)
    mailbox = new Webmail.Models.Mailbox(mailbox_sample 7)
    expect(mailbox.hasParent?()).toBe("Parent")

  # Test the title() function
  it "should return the mailboxe title", ->
    mailbox = new Webmail.Models.Mailbox(mailbox_sample 1)
    expect(mailbox.title()).toBe("INBOX")
    mailbox = new Webmail.Models.Mailbox(mailbox_sample 7)
    expect(mailbox.title()).toBe("Child")


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
