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
end
