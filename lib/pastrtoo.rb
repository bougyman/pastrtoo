$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

app_root = File.expand_path(File.join(File.expand_path(File.dirname(__FILE__)), ".."))
puts "app_root is #{app_root}"
requires = {}
requires[:models] = File.join(app_root, "model", "init")
requires.each_pair do |req,path|
  puts "Requiring %s: %s" % [req, path]
  require path
end
module Pastrtoo
  VERSION = '0.0.1'
end
