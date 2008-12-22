require File.join(File.dirname(__FILE__), "start_common")

Ramaze.start :load_engines => [:Ezamar, :Haml], :sourcereload => false
