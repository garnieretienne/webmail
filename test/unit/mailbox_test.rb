# encoding: utf-8
require 'test_helper'

class MailboxTest < ActiveSupport::TestCase
  
  # Helper to create a new mailbox for testing purpose without
  # mass addignement security problems.
  def register_mailbox(settings)
    mailbox             = Mailbox.new
    mailbox.name      ||= settings[:name]
    mailbox.delimiter ||= settings[:delimiter]
    mailbox.flag_attr ||= settings[:flag_attr]
    mailbox.account   ||= settings[:account]
    return mailbox
  end

  test "a mailbox must be owned by an account" do
    mailbox = register_mailbox(name: "Testing", delimiter: "/", flag_attr: "")
    assert !mailbox.valid?, "this is valid with no account_id"
  end

  test "a mailbox must have a name" do
    mailbox = register_mailbox(delimiter: "/", flag_attr: "", account: accounts(:one))
    assert !mailbox.valid?, "this is valid with no name"
  end

  test "a mailbox must have a delimiter" do
    mailbox = register_mailbox(name: "Testing", flag_attr: "", account: accounts(:one))
    assert !mailbox.valid?, "this is valid with no delimiter"
  end

  test "should return an array of symbol flags for a mailbox" do
    mailbox = mailboxes(:test)
    assert_equal Array, mailbox.flags.class
    assert_equal 2, mailbox.flags.count
    assert_equal Symbol, mailbox.flags.first.class

    mailbox = mailboxes(:hey)
    assert_equal Array, mailbox.flags.class
    assert_equal 0, mailbox.flags.count
  end

  test "should not list this inbox (not selectable)" do
    mailbox = mailboxes(:test)
    assert mailbox.flagged? :Noselect
  end

  test "remove a flag from the mailboxes flags" do
    mailbox = mailboxes(:test)
    flags = mailbox.flags
    flags.delete_at(0)
    mailbox.flags = flags
    assert_equal 1, mailbox.flags.count
  end

  test "messages synchronization" do
    account = accounts(:one)
    account.password = "imnotstrong"
    imap = account.connect
    inbox = account.mailboxes.find_by_name("INBOX")
    
    # Should discover the new message
    subject = new_message(accounts(:one).email_address)
    inbox.sync imap
    message = inbox.messages.find_by_subject(subject)
    assert_not_nil message
    assert_equal subject, message.subject
    assert !message.flagged?(:Seen), "the message is new but has the :Seen tag"

    # Should update the new message as read (flag: Seen)
    read_message accounts(:one).email_address, subject
    inbox.sync imap
    message = inbox.messages.find_by_subject(subject)
    assert message.flagged?(:Seen), "the message has not the :Seen tag"

    # Should remove the cached message (it was purged on the server)
    delete_message accounts(:one).email_address, subject
    inbox.sync imap
    message = inbox.messages.find_by_subject(subject)
    assert_nil message, "the message is not deleted"
  end

  test "should decode the name stored in UTF7" do
    utf7 = mailboxes(:utf7)
    assert_equal "Études", utf7.name
  end

  test "should return the name encoded in utf7" do
    utf7 = mailboxes(:utf7)
    assert_equal "&AMk-tudes", utf7.name_utf7
  end

  test "should store the given name in UTF7" do
    utf7 = mailboxes(:utf7)
    utf7.name = "é"
    assert utf7.save
    assert_equal "&AOk-", utf7.name_utf7
  end

  test "should store the given name already encoded in UTF7 without re-encoding it" do
    utf7 = mailboxes(:utf7)
    utf7.name_utf7 = "&AOk-"
    assert utf7.save
    assert_equal "&AOk-", utf7.name_utf7
  end
end
