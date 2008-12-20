# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers

class Controller < Ramaze::Controller
  layout '/page'
  helper :xhtml
  engine :Ezamar
end

Dir[File.join(File.dirname(__FILE__), "*.rb")].each { |controller| require controller }
