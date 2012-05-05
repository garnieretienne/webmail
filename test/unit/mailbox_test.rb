require 'test_helper'

class MailboxTest < ActiveSupport::TestCase
  
  # Helper  to create a new mailbox for testing purpose without
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
end
