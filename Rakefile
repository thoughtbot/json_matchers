require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rake/testtask"

RSpec::Core::RakeTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end

Rake::TestTask.new do |t|
  t.test_files = FileList["test/**/*_test.rb"]
end

task(:default).clear
task default: [:spec, :test]
