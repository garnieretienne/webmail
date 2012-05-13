# This class is an Active Record object to manage cached mailboxes for accounts.
# The flags are not stored into their own Active::Record class,
# They are stored into the 'flag_attr' attribute as a string and 
# managed with the 'flags', 'flags=' and 'flagged?' functions.
class Mailbox < ActiveRecord::Base
  # Use Net::IMAP functionnalities
  require 'net/imap'

  attr_accessible :delimiter, :name, :name_utf7

  # A mailbox belongs to an account and
  # has many messages
  belongs_to :account
  has_many :messages, dependent: :destroy

  # The name, delimiter and account related must be specified
  validates :name, :delimiter, :account_id, presence: true

  # Return an array of flags
  #   mailbox.flags.each do |flag|
  #     ... do your stuff
  #   end
  def flags
    flags = Array.new
    if self.flag_attr
      self.flag_attr.split(", ").each do |flag|
        flags << flag.to_sym
      end
    end

    return flags
  end

  # Transform an array of Flags into a storable string
  # and store it into the flag_attr attribute
  #   new_flags = [:Noselect, :Hasnochild]
  #   mailbox.flags = new_flags
  def flags=(flags)
    self.flag_attr = flags.map{|flag| flag.to_s}.join(", ");
  end

  # Test if a mailbox is flagged with a specific flag
  #   if mailbox.flagged?(:Noselect)
  #     ... do your stuff ...
  #   end
  def flagged?(flag)
    self.flags.include? flag
  end

  # Modify the default JSON object
  def as_json(options = {})
    super(options.merge(except: [ :account_id, :flag_attr ], :methods => [ :flags ]))
  end

  # Sync all the mails for this mailbox
  # Use RFC4549
  # see: http://tools.ietf.org/html/rfc4549
  #   Sync:
  #     - find all new messages
  #     - get status for all old messages
  #     - for all cached messages: delete if no more present on the server OR update flags if have changed
  #     - insert all new messages into the database
  def sync(imap_password)

    # Load the IMAP account password in memory
    self.account.password = imap_password

    # Find all messages UID
    cached_messages = self.messages.select([:uid, :flag_attr])

    # Grab the last seen message UID
    last_uid = (!cached_messages.empty?) ? cached_messages.last.uid : 0

    # Ask the server for new messages and
    # ask the server for changes to old messages
    new_messages = nil
    old_messages = nil
    self.account.connect do |imap|
      imap.select self.name_utf7
      new_messages = imap.uid_fetch(last_uid+1..-1, ["UID", "ENVELOPE", "FLAGS", "INTERNALDATE"])
      old_messages = imap.uid_fetch(1..last_uid, ["UID", "FLAGS"]) if last_uid > 0
    end

    # Update cache for old messages
    if cached_messages

      # Build a table of cached flags
      cached_messages_flags = Hash.new
      cached_messages.each do |message|
        cached_messages_flags[message.uid] = message.flags
      end

      # Build a table of current flags
      current_messages_flags = Hash.new
      if old_messages
        old_messages.each do |message_data|
          current_messages_flags[message_data.attr["UID"]] = message_data.attr["FLAGS"]
        end
      end

      # Delete expurged messages and update flags
      cached_messages_flags.each do |uid, flags|
        if !current_messages_flags[uid]
          message = self.messages.find_by_uid(uid)
          message.destroy
        elsif current_messages_flags[uid] != flags
          message = self.messages.find_by_uid(uid)
          message.flags = current_messages_flags[uid]
          message.save
        end
      end
    end

    # Cache new messages
    # Break if the new message UID is the last_uid 
    # (the server can send the last UID if no new messages has been found in the range)
    if new_messages
      new_messages.each do |message_data|
        next if message_data.attr["UID"] == last_uid
        message = self.messages.new(
          from_address:  "#{message_data.attr["ENVELOPE"].from.first.mailbox}@#{message_data.attr["ENVELOPE"].from.first.host}",
          from_name:     message_data.attr["ENVELOPE"].from.first.name,
          internal_date: message_data.attr["INTERNALDATE"],
          subject:       message_data.attr["ENVELOPE"].subject,
          uid:           message_data.attr["UID"]
        )
        message.flags =  message_data.attr["FLAGS"]
        message.save
      end
    end
  end

  # Overwrite the name attribute getter, decode using utf7
  # see: http://www.ruby-doc.org/stdlib-1.9.3/libdoc/net/imap/rdoc/Net/IMAP.html#method-c-decode_utf7
  def name
    Net::IMAP.decode_utf7 self.read_attribute(:name) if self[:name]
  end  

  # Overwrite the name attribute setter, encode using utf7
  # see: http://www.ruby-doc.org/stdlib-1.9.3/libdoc/net/imap/rdoc/Net/IMAP.html#method-c-encode_utf7
  def name=(name)
    encoded_name = (name) ? Net::IMAP.encode_utf7(name) : ""
    write_attribute(:name, encoded_name)
  end

  # Overwrite the find_by_name method
  # see: http://www.ruby-doc.org/stdlib-1.9.3/libdoc/net/imap/rdoc/Net/IMAP.html#method-c-encode_utf7
  def self.find_by_name(name)
    encoded_name = Net::IMAP.encode_utf7(name)
    Mailbox.where(name: encoded_name).first
  end

  # Return the name encoded in utf7
  def name_utf7
    self.read_attribute(:name)
  end

  # Write a name attribute already encoded in utf7
  def name_utf7=(name)
    write_attribute(:name, name)
  end
end
