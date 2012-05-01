# This class is an Active Record object to manage cached mailboxes for accounts.
# The flags are not stored into their own Active::Record class,
# They are stored into the 'flag_attr' attribute as a string and 
# managed with the 'flags', 'flags=' and 'flagged?' functions.
class Mailbox < ActiveRecord::Base
  attr_accessible :delimiter, :name

  # A mailbox belongs to an account
  belongs_to :account

  # The name, delimiter and account related must be specified
  validates :name, :delimiter, :account_id, presence: true

  # Return an array of flags
  #   mailbox.flags.each do |flag|
  #     ... do your stuff
  #   end
  def flags
    flags = Array.new
    self.flag_attr.split(", ").each do |flag|
      flags << flag.to_sym
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
end
