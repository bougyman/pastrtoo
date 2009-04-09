$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

app_root = File.expand_path(File.join(File.expand_path(File.dirname(__FILE__)), ".."))
puts "app_root is #{app_root}"
module Pastrtoo
  VERSION = '0.0.1'
end
