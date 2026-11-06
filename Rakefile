require "bundler/setup"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test" << "lib"
  t.pattern = "test/**/*_test.rb"
end

task default: :test

desc "Regenerate the component images in docs/images used by the README"
task :screenshots do
  ruby "script/screenshots.rb"
end
