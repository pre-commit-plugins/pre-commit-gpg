=begin
Copyright 2014 Michal Papis <mpapis@gmail.com>

See the file LICENSE for copying permission.
=end

require "rake/testtask"

Rake::TestTask.new do |test|
  test.libs << "test" << "lib"
  test.pattern = "test/**/*_test.rb"
  test.verbose = true
end

task :ci => [:test]
task :default => [:test]
