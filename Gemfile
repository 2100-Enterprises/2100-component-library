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

# Serve the pages that `rake test:system` and `rake lookbook` drive in a browser. stimulus-rails
# and turbo-rails are there for their JavaScript files, which both pages load.
group :development, :test do
  gem "puma"
  gem "stimulus-rails", require: false
  gem "turbo-rails", require: false
end

# Only needed for `rake test:system`, which drives the Stimulus controllers in headless Chrome.
group :test do
  gem "selenium-webdriver"
end

# Only needed for `rake screenshots`, which regenerates the README images, and `rake lookbook`,
# which browses the previews in previews/.
group :development do
  gem "ferrum"
  gem "lookbook", "~> 2.3", require: false
  gem "tailwindcss-ruby", "~> 4.0"
end
