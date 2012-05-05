# This class is an Active Record object to manage cached message attributes.
# The flags are not stored into their own Active::Record class,
# They are stored into the 'flag_attr' attribute as a string and 
# managed with the 'flags', 'flags=' and 'flagged?' functions.
class Message < ActiveRecord::Base
  attr_accessible :envelope, :from, :internal_date, :subject, :uid

  # A message belongs to a mailbox
  belongs_to :mailbox

  # The uid, from, internal_date, flag_attr, envelope and related mailbox must be specified
  validates :uid, :from_address, :internal_date, :mailbox_id, presence: true

  # The email in the from field must be in a good format
  validates :from_address, email_format: true

  # Return an array of flags
  #   message.flags.each do |flag|
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
  #   message.flags = new_flags
  def flags=(flags)
    self.flag_attr = flags.map{|flag| flag.to_s}.join(", ");
  end

  # Test if a message is flagged with a specific flag
  #   if message.flagged?(:Read)
  #     ... do your stuff ...
  #   end
  def flagged?(flag)
    self.flags.include? flag
  end
end
