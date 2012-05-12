source 'https://rubygems.org'

gem 'rails', '3.2.3'
gem 'jquery-rails'
gem "haml-rails"         # Use haml for rails templates
gem 'backbone-on-rails'  # Use backbone

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'therubyracer', platform: :ruby  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'uglifier', '>= 1.0.3'
  gem 'twitter-bootstrap-rails'        # Use twitter bootstrap with less
  gem 'haml_coffee_assets'             # Use haml templating with coffee script for javascript
end

group :development do
  gem 'sqlite3'
  gem 'debugger'                                                         # Debugger for ruby 1.9.3
  gem 'jasminerice', git: "git://github.com/bradphelan/jasminerice.git"  # Jasmine + coffee script and assets support
end

group :test do
  gem 'gmail'
end
