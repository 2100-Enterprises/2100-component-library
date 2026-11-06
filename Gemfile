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

# Only needed for `rake screenshots`, which regenerates the README images.
group :development do
  gem "ferrum"
  gem "tailwindcss-ruby", "~> 4.0"
end
