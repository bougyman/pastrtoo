require 'rubygems'
$:.unshift(File.join(File.dirname(__FILE__), "vendor", "ramaze", "lib"))
require 'ramaze'

# Initialize controllers and models
require File.join(File.dirname(__FILE__), 'controller', 'init')
require File.join(File.dirname(__FILE__), 'model', 'init')

Ramaze::Route["/admin"] = "/"
