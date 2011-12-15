source 'http://rubygems.org'
source 'https://gems.gemfury.com/vo6ZrmjBQu5szyywDszE/'

# passenger compatability
group :passenger_compatibility do
  gem 'rack', '1.3.5'
  gem 'rake'
end

group :router do
  gem 'router-client', '2.0.3', :require => 'router/client'
end

gem 'rails', '3.1.1'
gem 'rails-i18n'
gem 'json'
gem 'jquery-rails'
gem 'plek', '~> 0.1'
gem 'rummageable', :git => 'git@github.com:alphagov/rummageable.git'

group :development do
  gem 'ruby-debug19', :require => false
end

if ENV['SLIMMER_DEV']
  gem 'slimmer', :path => '../slimmer'
else
  gem 'slimmer', '~> 1.1'
end

if ENV['GOVSPEAK_DEV']
  gem 'govspeak', :path => '../govspeak'
else
  gem 'govspeak', :git => 'git@github.com:alphagov/govspeak.git'
end

group :test do
  gem 'capybara', '~> 1.1.0'
  gem 'ci_reporter'
  gem 'factory_girl_rails'
  gem 'mocha', :require => false
  gem 'selenium-webdriver'
  gem "shoulda", "~> 2.11.3"
  gem 'webmock', :require => false
end

group :webkit do
  gem 'capybara-webkit'
end

group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem "therubyracer", "~> 0.9.4"
  gem 'uglifier'
end
