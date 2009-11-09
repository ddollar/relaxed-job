require 'rubygems'
require 'rake'

$:.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'relaxed_job/tasks'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "relaxed-job"
    gem.summary = %Q{Relaxed Job}
    gem.description = gem.summary
    gem.email = "<ddollar@gmail.com>"
    gem.homepage = "http://github.com/ddollar/relaxed-job"
    gem.authors = ["David Dollar"]

    gem.add_development_dependency "rspec"

    gem.add_dependency "couchrest"
    gem.add_dependency "libdir"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "relaxed-job #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
