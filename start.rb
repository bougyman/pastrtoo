require 'rubygems'
$:.unshift(File.join(File.dirname(__FILE__), "vendor", "ramaze", "lib"))
require 'ramaze'

# Initialize controllers and models
require 'controller/init'
require 'model/init'

Ramaze::Route["/admin"] = "/"
Ramaze.start :adapter => :webrick, :port => 7000, :load_engines => [:Ezamar, :Haml]
