ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Parse response in JSON
  def json_response
    decode @response.body
  end

  # Rewrite of ActiveSupport::JSON.decode
  # see: http://api.rubyonrails.org/classes/ActiveSupport/JSON.html#method-c-decode
  # 'decode' action is deprecated and an annoying message appears on each tests using this function.
  # see: https://github.com/colszowka/simplecov/pull/121
  def decode(json, options ={})
    data = MultiJson.load(json, options)
    if ActiveSupport.parse_json_times
      convert_dates_from(data)
    else
      data
    end
  end

  # Send an email to the given account
  def new_message(address)
    subject = Time.now.to_i.to_s
    Gmail.connect(address, "imnotstrong") do |gmail|
      status = gmail.deliver do
        to address
        subject subject
        body "Testing ..."
      end
      found = []
      until !found.empty?
        found = gmail.inbox.find(subject: subject)
      end
    end
    return subject
  end

  # Read an email on the given account
  def read_message(address, subject)
    Gmail.connect(address, "imnotstrong") do |gmail|
      email = gmail.inbox.find(subject: subject).first
      email.read!
    end
  end
  
  # Delete an email on the given account
  def delete_message(address, subject)
    Gmail.connect(address, "imnotstrong") do |gmail|
      email = gmail.inbox.find(subject: subject).first
      email.delete!
      found = [""]
      until found.empty?
        found = gmail.inbox.find(subject: subject)
      end
    end
  end

  # Create a mailbox on the given account
  def add_mailbox(address, name)
    Gmail.connect(address, "imnotstrong") do |gmail|
      gmail.labels.new(name)
    end
  end

  # Delete a mailbox on the given account
  def delete_mailbox(address, name)
    Gmail.connect(address, "imnotstrong") do |gmail|
      gmail.labels.delete(name)
    end
  end
end
