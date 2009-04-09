%w[rubygems rake rake/clean fileutils].each { |f| require f }
require File.dirname(__FILE__) + '/lib/pastrtoo'
require File.dirname(__FILE__) + '/lib/pastr_it'

GEMSPEC = Gem::Specification.new do |spec|
  spec.name = "pastr_it"
  spec.version = PastrIt::VERSION
  spec.add_dependency "httpclient"
  spec.summary = 'A command line program to paste text to http://pastr.it'
  spec.authors = ["Jayson Vaughn", "Michael Fellinger", "Kevin Berry", "TJ Vanderpoel"]
  spec.email = "admins@rubyists.com"
  spec.homepage = "http://code.rubyists.com/projects/pastrtoo"

  spec.files = ["lib/pastr_it.rb", "bin/pastr-it"]
  spec.executables = ["pastr-it"]
  spec.require_path = "lib"
  spec.post_install_message = "
  See pastr-it -h for usage.  
  A pastr.it account is required for use. 
  You can register for an account by messaging Pastr on Freenode:
    /msg Pastr .register <somepassword>
  "

end

PROJECT_SPECS = Dir["specs/**.rb"]
# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# task :default => [:spec, :features]
