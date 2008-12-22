#!/usr/bin/env ruby

require 'rubygems'
require 'ramaze'

# FCGI doesn't like you writing to stdout
Ramaze::Log.loggers = [ Ramaze::Logger::Informer.new( File.join(__DIR__, '..', 'ramaze.fcgi.log') ) ]
Ramaze::Global.adapter = :fcgi

$0 = File.join(__DIR__, '..', 'start_common')
require $0
Ramaze.start :sourcereload => false, :adapter => :fcgi, :load_engines => [:Ezamar, :Haml]
