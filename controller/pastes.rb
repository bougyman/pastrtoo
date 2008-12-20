# Default url mappings are:
#  a controller called Main is mapped on the root of the site: /
#  a controller called Something is mapped on: /something
# If you want to override this, add a line like this inside the class
#  map '/otherurl'
# this will force the controller to be mounted on: /otherurl
require "uv"
Ramaze::Route[ %r!^/pastes/(\d+)$! ] = "/pastes/view/%d"
class PastesController < Controller
  # the index action is called automatically when no other action is specified
  def index(paste_id = nil)
    @title = "Welcome to Pastr!"
    @paste_entries = PasteEntry.order(:id.desc).paginate(1,10)
  end

  def view(paste_id, filename = nil)
    @paste_entry = PasteEntry[paste_id]
    if filename
      respond(@paste_entry.paste_body, 200, 'Content-Type' => "text/plain")
    else
      @title = @paste_entry.title || "Paste number #{paste_id}"
    end
  end

  # the string returned at the end of the function is used as the html body
  # if there is no template for the action. if there is a template, the string
  # is silently ignored
  def notemplate
    "there is no 'notemplate.xhtml' associated with this action"
  end
end
