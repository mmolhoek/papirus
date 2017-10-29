# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'
require 'juwelier'
Juwelier::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "papirus"
  gem.homepage = "http://github.com/mmolhoek/papirus"
  gem.license = "MIT"
  gem.summary = %Q{ruby gem to access the PaPiRus display}
  gem.description = %Q{This gem can be used to talk to the PaPiRus e-paper display}
  gem.email = "mischamolhoek@gmail.com"
  gem.authors = ["Mischa Molhoek"]

  # dependencies defined in Gemfile
  gem.files = Dir.glob('lib/**/*.rb')
end

Juwelier::RubygemsDotOrgTasks.new
require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['test'].execute
end

task :default => :test

require 'yard-doctest'
YARD::Doctest::RakeTask.new do |task|
    task.doctest_opts = %w[-v]
    task.pattern = 'lib/*.rb'
end
