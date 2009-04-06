%w[rubygems rake rake/clean fileutils].each { |f| require f }
require File.dirname(__FILE__) + '/lib/pastrtoo'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# task :default => [:spec, :features]
