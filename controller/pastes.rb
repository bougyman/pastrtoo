# Default url mappings are:
#  a controller called Main is mapped on the root of the site: /
#  a controller called Something is mapped on: /something
# If you want to override this, add a line like this inside the class
#  map '/otherurl'
# this will force the controller to be mounted on: /otherurl
Ramaze::Route[ %r!^/(\d+)/(\w.*)$! ] = "/pastes/view/%d/%s"
Ramaze::Route[ %r!^/(\d+)$! ] = "/pastes/view/%d"
Ramaze::Route[ %r!^/(\d+)/(-\w+)$! ] = "/pastes/edit/%d/%s"
class PastesController < Controller
  # the index action is called automatically when no other action is specified
  def index(paste_id = nil)
    @title = "Welcome to Pastr!"
    @paste_entries = PasteEntry.order(:id.desc).filter("paste_body is not null").paginate(1,10)
  end

  def annotate(paste_id)
    @paste_entry = PasteEntry[paste_id]
  end

  def edit(paste_id, key = nil)
    @title = "Editing Paste #{paste_id}"
    @paste_entry = PasteEntry[paste_id]
    @paste_entry.filter = Filter.find(:filter_name => "Plain Text") if @paste_entry.filter.nil?
    unless key == @paste_entry.paste_key
      flash[:ERRORS] = {"Key" => "does not match paste key"}
      redirect R(PastesController)
    else
      render_template("edit.haml")
    end
  end

  def view(paste_id, filename = nil)
    require "coderay"
    require "uv"
    @paste_entry = PasteEntry[paste_id]
    if filename
      respond(@paste_entry.paste_body.to_s, 200, 'Content-Type' => "text/plain")
    else
      @title = @paste_entry.title || "Paste number #{paste_id}"
    end
    render_template("view.haml")
  end

  def update(paste_id, key)
    @paste_entry = PasteEntry[paste_id]
    unless key == @paste_entry.paste_key
      flash[:ERRORS] = {"Key" => "does not match paste key"}
      redirect R(PastesController)
    end
    if filter = Filter[request["paste_entry"]["filter_id"]]
      @paste_entry.update_with_params(request["paste_entry"])
      flash[:INFO] = {"Paste #{@paste_entry.id}" => "updated successfully"}
    end
    @title = @paste_entry.title || "Paste number #{paste_id}"
    redirect Rs(:view, @paste_entry.id)
  end

  # the string returned at the end of the function is used as the html body
  # if there is no template for the action. if there is a template, the string
  # is silently ignored
  def notemplate
    "there is no 'notemplate.xhtml' associated with this action"
  end
end
