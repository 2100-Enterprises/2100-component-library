require "bundler/setup"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test" << "lib"
  t.test_files = FileList["test/**/*_test.rb"].exclude("test/system/**/*")
end

namespace :test do
  desc "Run the browser tests in test/system, which need Chrome installed"
  Rake::TestTask.new(:system) do |t|
    t.libs << "test" << "lib"
    t.pattern = "test/system/**/*_test.rb"
  end
end

task default: :test

desc "Regenerate the component images in docs/images used by the README"
task :screenshots do
  ruby "script/screenshots.rb"
end

desc "Browse the component previews in previews/ with Lookbook at http://localhost:4000 (PORT to change it)"
task :lookbook do
  sh "bundle", "exec", "puma", "--port", ENV.fetch("PORT", "4000"), "lookbook/config.ru"
end
