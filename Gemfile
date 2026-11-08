source "https://rubygems.org"

gemspec

group :development, :test do
  gem "bundler-audit", require: false
  gem "capybara"
  gem "minitest"
  gem "rake"
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
end

# Only needed for `rake test:system`, which drives the Stimulus controllers in headless Chrome.
# stimulus-rails and turbo-rails are there for their JavaScript files, which the test page serves.
group :test do
  gem "puma"
  gem "selenium-webdriver"
  gem "stimulus-rails", require: false
  gem "turbo-rails", require: false
end

# Only needed for `rake screenshots`, which regenerates the README images.
group :development do
  gem "ferrum"
  gem "tailwindcss-ruby", "~> 4.0"
end
