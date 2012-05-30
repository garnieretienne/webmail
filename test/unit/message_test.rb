# encoding: utf-8
require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  
  # Helper  to create a new message for testing purpose without
  # mass addignement security problems.
  def register_message(settings)
    message                 = Message.new
    message.uid           ||= settings[:uid]
    message.subject       ||= settings[:subject]
    message.from_name     ||= settings[:from_name]
    message.from_address  ||= settings[:from_address]
    message.internal_date ||= settings[:internal_date]
    message.flag_attr     ||= settings[:flag_attr]
    message.mailbox       ||= settings[:mailbox]
    return message
  end

  test "a message must be owned by a mailbox" do
    message = register_message(
      uid: '12345', 
      subject: 'Hello', 
      from_address: 'kurt@yuweb.fr', 
      internal_date: '2012-05-04 17:02:56',
      flag_attr: [],
    )
    assert !message.valid?, "this is valid with no mailbox" 
  end

  test "a message must have an uid" do
    message = register_message(
      subject: 'Hello', 
      from_address: 'kurt@yuweb.fr', 
      internal_date: '2012-05-04 17:02:56',
      flag_attr: [],
      mailbox: mailboxes(:inbox)
    )

    assert !message.valid?, "this is valid with no uid" 
  end

  test "a message uid must be unique" do
    message = register_message(
      subject: 'Hello', 
      uid: "12345",
      from_address: 'kurt@yuweb.fr', 
      internal_date: '2012-05-04 17:02:56',
      flag_attr: [],
      mailbox: mailboxes(:inbox)
    )
    assert message.save, "the first message was not saved"
    message = register_message(
      subject: 'Hello', 
      uid: "12345",
      from_address: 'kurt@yuweb.fr', 
      internal_date: '2012-05-04 17:02:56',
      flag_attr: [],
      mailbox: mailboxes(:inbox)
    )
    assert !message.save, "the same message (same UID) was saved two times"
  end

  test "a message must have a from address field" do
    message = register_message(
      uid: '12345', 
      subject: 'Hello', 
      internal_date: '2012-05-04 17:02:56',
      flag_attr: [],
      mailbox: mailboxes(:inbox)
    )

    assert !message.valid?, "this is valid with no from address field" 
  end

  test "a message must have an internal date" do
    message = register_message(
      uid: '12345', 
      subject: 'Hello', 
      from_address: 'kurt@yuweb.fr', 
      flag_attr: [],
      mailbox: mailboxes(:inbox)
    )

    assert !message.valid?, "this is valid with no internal date" 
  end  

  test "should validate this message" do
    message = register_message(
      uid: '12345', 
      subject: 'Hello', 
      internal_date: '2012-05-04 17:02:56',
      flag_attr: [],
      from_address: 'kurt@yuweb.fr',
      mailbox: mailboxes(:inbox)
    )

    assert message.valid?, "this message must be validated" 
  end

  test "from address must be a valid email address" do
    message = register_message(
      uid: '12345', 
      subject: 'Hello', 
      from_address: 'kurt', 
      internal_date: '2012-05-04 17:02:56',
      flag_attr: [],
      mailbox: mailboxes(:inbox)
    )

    assert !message.valid?, "this is valid with no valid formatted email address"
  end

  test "should return an array of symbol flags for the message" do
    message = messages(:two)
    assert_equal Array, message.flags.class
    assert_equal 2, message.flags.count
    assert_equal Symbol, message.flags.first.class

    message = messages(:one)
    assert_equal Array, message.flags.class
    assert_equal 0, message.flags.count
  end

  test "remove a flag from the messages flags" do
    message = messages(:two)
    flags = message.flags
    flags.delete_at(0)
    message.flags = flags
    assert_equal 1, message.flags.count
  end

  test "should return this message as read" do
    message = messages(:two)
    assert message.flagged?(:Seen), "this message is not masked as read but is"
  end

  test "should return the subject decoded using RFC2047" do
    message = messages(:three)
    assert_equal "Encoded using RFC2047 @é!", message.subject
  end

  test "should get the body of an existing message" do
    # create a new message
    account = accounts(:one)
    account.password = "imnotstrong"
    imap = account.connect
    inbox = account.mailboxes.find_by_name("INBOX")
    subject = new_message(accounts(:one).email_address)

    # synchronize the mailbox
    inbox.sync imap

    # try to get the body of the cached message
    message = inbox.messages.find_by_subject subject
    message.get_body! imap

    assert_equal "Testing ...", message.body

    # delete the message from the mailbox
    delete_message accounts(:one).email_address, subject
    imap.logout
  end

  test "encoding on message body" do
    # create a new message
    account = accounts(:one)
    account.password = "imnotstrong"
    imap = account.connect
    inbox = account.mailboxes.find_by_name("INBOX")
    subject = new_encoded_message(accounts(:one).email_address)

    # synchronize the mailbox
    inbox.sync imap

    # try to get the body of the cached message
    message = inbox.messages.find_by_subject subject
    message.get_body! imap

    assert_equal "éééé", message.body

    # delete the message from the mailbox
    delete_message accounts(:one).email_address, subject
    imap.logout
  end
end