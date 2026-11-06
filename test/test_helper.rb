ENV["RAILS_ENV"] = "test"

require "bundler/setup"
require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "capybara"
require "capybara/minitest"
require "active_support/test_case"
require "minitest/autorun"
require "component_library_2100"

# A tiny in-process Rails app so the engine boots exactly as it would in a host app.
class DummyApp < Rails::Application
  config.root = File.expand_path("..", __dir__)
  config.eager_load = false
  config.secret_key_base = "test"
  config.logger = Logger.new(nil)
end

DummyApp.initialize!

# ViewComponent 4 renders tests through ApplicationController unless told otherwise.
class ApplicationController < ActionController::Base; end

require "view_component/test_case"
