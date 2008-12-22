# Default url mappings are:
#  a controller called Main is mapped on the root of the site: /
#  a controller called Something is mapped on: /something
# If you want to override this, add a line like this inside the class
#  map '/otherurl'
# this will force the controller to be mounted on: /otherurl

Ramaze::Route["/admin"] = "/"

class MainController < Controller
  def error()
    "An unexpected error has occurred, you get the Dunce Cap"
  end
  # the index action is called automatically when no other action is specified
  def index
    @title = "Welcome to Pastr!"
  end

  # the string returned at the end of the function is used as the html body
  # if there is no template for the action. if there is a template, the string
  # is silently ignored
  def notemplate
    "there is no 'notemplate.xhtml' associated with this action"
  end
end
