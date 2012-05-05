# This class is an Active Record object to manage cached mailboxes for accounts.
# The flags are not stored into their own Active::Record class,
# They are stored into the 'flag_attr' attribute as a string and 
# managed with the 'flags', 'flags=' and 'flagged?' functions.
class Mailbox < ActiveRecord::Base
  attr_accessible :delimiter, :name

  # A mailbox belongs to an account and
  # has many messages
  belongs_to :account
  has_many :messages

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
end
