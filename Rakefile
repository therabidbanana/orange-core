require 'rake/clean'
require 'spec/stats.rb'

begin
  require 'rspec/core/rake_task'
rescue LoadError
  puts "(No rspec)"
end

begin
  require 'jeweler'
rescue LoadError
  puts "(No jeweler)"
end


Jeweler::Tasks.new do |gemspec|
  gemspec.name = "orange-core"
  gemspec.summary = "Middle ground between Sinatra and Rails"
  gemspec.description = "Orange is a Ruby framework for building managed websites with code as simple as Sinatra"
  gemspec.email = "david@orangesparkleball.com"
  gemspec.homepage = "http://github.com/orange-project/orange-core"
  gemspec.authors = ["David Haslem"]
  gemspec.files = FileList['lib/**/*']
  gemspec.test_files = FileList['spec/**/*.rb']
  gemspec.add_dependency('rack', '>= 1.0.1')
  gemspec.add_dependency('haml', '>= 2.2.13')
  gemspec.add_dependency('tilt', '~> 1.1')
  gemspec.add_dependency('crack', ">= 0")
  gemspec.add_dependency('dm-core', '>= 1.0.0')
  gemspec.add_dependency('dm-migrations', '>= 1.0.0')
  gemspec.add_development_dependency "rspec", ">= 0"
  gemspec.add_development_dependency "rack-test", ">= 0"
  gemspec.post_install_message = <<-DOC
===========================================
Note: 
orange-core requires DataMapper to function. dm-core has been installed,
but please make sure you also have installed the 
the appropriate DataMapper adapter for your system:

$ gem install [dm-adapter]

Mysql:    dm-mysql-adapter
Sqlite:   dm-sqlite-adapter
Postgres: dm-postgres-adapter

orange-core install complete.
===========================================
DOC
end
Jeweler::GemcutterTasks.new

desc "Report code statistics on the application and specs code"
task :stats do
  stats_directories = {
      "Specs" => "spec",
      "Application" => "lib"
    }.map {|name, dir| [name, "#{Dir.pwd}/#{dir}"]}
  SpecStatistics.new(*stats_directories).to_s
end

CLEAN = Rake::FileList['doc/', 'coverage/', 'db/*']

desc "Test is same as running specs"
task :test => :spec

desc "rcov is same as running specs_with_rcov"
task :rcov => :specs_with_rcov

desc "Default task is to run tests"
task :default => :spec

desc "Generate documentation with yard"
task :doc do
  sh "yardoc"
end

desc "Opens Coverage File"
task :show_cov do
  sh "open coverage/index.html"
end

desc "Run the specs under spec"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w[--require spec/orange-core/spec_helper.rb --colour --format progress]
  t.pattern = 'spec/**/*_spec.rb'
end

desc "Run all specs with RCov"
RSpec::Core::RakeTask.new('specs_with_rcov') do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec,1.8/gems,1.9/gems']
end

desc "Runs basic example"
task :serve, :server do |t, args|
  opts = {:server => 'basic'}.merge args
  cd "./examples/#{opts[:server]}"
  sh "rackup"
end