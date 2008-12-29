# Default url mappings are:
#  a controller called Main is mapped on the root of the site: /
#  a controller called Something is mapped on: /something
# If you want to override this, add a line like this inside the class
#  map '/otherurl'
# this will force the controller to be mounted on: /otherurl

Ramaze::Route[ %r!^/pasters/(\w[^/]*?)$! ] = "/pasters/index/%s"
class PastersController < Controller
  # the index action is called automatically when no other action is specified
  def index(paster_nickname)
    @paster = Paster.find(:nickname => paster_nickname)
    paster_not_found(paster_nickname) if @paster.nil?
    @title = "Pastes for #{paster_nickname}"
    @paste_entries = PasteEntry.filter(:paster_id => @paster.id).order(:id.desc)
    render_template("index.xhtml")
  end

  # the string returned at the end of the function is used as the html body
  # if there is no template for the action. if there is a template, the string
  # is silently ignored
  def notemplate
    "there is no 'notemplate.xhtml' associated with this action"
  end
  private

  def paster_not_found(paster_nickname)
    @title = "An Error Has Occured"
    @content = "Paster #{paster_nickname} not found"
    respond(render_template("page.haml"))
  end
end
PastersController.view_root "view/pastes"
