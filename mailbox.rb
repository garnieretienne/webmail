# This class is an Active Record object to manage cached mailboxes for accounts.
# The flags are not stored into their own Active::Record class,
# They are stored into the 'flag_attr' attribute as a string and 
# managed with the 'flags', 'flags=' and 'flagged?' functions.
class Mailbox < ActiveRecord::Base
  # Use Net::IMAP functionnalities
  require 'net/imap'

  attr_accessible :delimiter, :name

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
  def sync(imap)

    # Find all messages UID
    cached_messages = self.messages.select([:uid, :flag_attr])

    # Grab the last seen message UID
    last_uid = (!cached_messages.empty?) ? cached_messages.last.uid : 0

    # Discovering new messages
    # Use -1 for *: 100:* => 100..-1
    fetch_data = imap.uid_fetch(last_uid+1..-1, ["UID", "ENVELOPE", "FLAGS", "INTERNALDATE"])
    if fetch_data 
      fetch_data.each do |msg|
        # the server can return the last email already cached if no new messages
        if msg.attr["UID"] != last_uid
          message = self.messages.new(
            from_address:  "#{msg.attr["ENVELOPE"].from.first.mailbox}@#{msg.attr["ENVELOPE"].from.first.host}",
            from_name:     msg.attr["ENVELOPE"].from.first.name,
            internal_date: msg.attr["INTERNALDATE"],
            subject:       msg.attr["ENVELOPE"].subject,
            uid:           msg.attr["UID"]
          )
          message.flags = msg.attr["FLAGS"]
          message.save
        end
      end
    end

    # Find all older messages
    if !cached_messages.empty?

      old_messages = Array.new
      #fetch_data = imap.uid_fetch(0..last_uid, ["UID", "FLAGS"])
      begin
        fetch_data = imap.uid_fetch(1..last_uid, ["UID", "FLAGS"])
      rescue Net::IMAP::BadResponseError => e
        #debugger
        # WHY !?
      end
      if fetch_data
        fetch_data.each do |msg|
          old_messages << msg
        end
      end

      # Cached messages: Build map of UID -> Flags
      cached_uid_flag_map = Hash.new
      cached_messages.each do |message|
        cached_uid_flag_map[message.uid] = message.flags
      end

      # Old messages: Build map of UID -> Flags
      old_uid_flag_map = Hash.new
      old_messages.each do |msg|
        old_uid_flag_map[msg.attr["UID"]] = msg.attr["FLAGS"]
      end

      # Update flags on cached messages
      old_uid_flag_map.each do |uid, flags|
        if cached_uid_flag_map[uid] != flags
          message = self.messages.find_by_uid(uid)
          message.flags = flags
          message.save
        end
      end

      # Find expurged old messages
      if old_messages.count != cached_messages.count
        cached_uid = cached_messages.map{|message| message.uid}
        old_uid = old_messages.map{|msg| msg.attr["UID"]}
        expurged = cached_uid - old_uid
        expurged.each do |uid|
          message = self.messages.find_by_uid(uid)
          message.destroy
        end
      end
    end
  end
end
