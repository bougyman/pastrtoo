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

  def common_annotate(paste_id)
    @title = "Annotating Paste #{paste_id}"
    @annotation = Annotation.new
    @captcha = CAPTCHA::Web.new(:image_dir => File.join(File.dirname(__FILE__), "..", "public/img"), :font => "/usr/share/fonts/truetype/ttf-bitstream-vera/Vera.ttf")
    @captcha.image
    @captcha.clean
  end
  private :common_annotate

  def annotate(paste_id)
    require "captcha"
    @paste_entry = PasteEntry[paste_id]
    common_annotate(paste_id)
  end

  def add_annotation(paste_id)
    require "captcha"
    captcha_digest = request["captcha_digest"]
    captcha_key    = request["captcha_key"]
    @paste_entry = PasteEntry[paste_id]
    unless CAPTCHA::Web.is_valid(captcha_key, captcha_digest)
      flash[:ERRORS] = "Invalid Captcha"
      common_annotate(paste_id)
      render_template("annotate.haml")
    else
      nickname = request[:nickname].to_s
      nickname = "Anonymous Coward" if nickname == ""
      unless paster = Paster[:nickname => nickname]
        paster = Paster.create(:nickname => nickname)
      end
      annotation = Annotation.create({:channel => @paste_entry.channel, :paste_entry_id => paste_id, :paster_id => paster.id}.merge(request["annotation"]))
      if annotation.nil?
        flash[:ERRORS] = "Failed to annotate!"
        common_annotate(paste_id)
        render_template("annotate.haml")
      else
        flash[:INFO] = "Annotation created"
        redirect R("/#{paste_id}")
      end
    end
  end

  def edit(paste_id, key = nil)
    @title = "Editing Paste #{paste_id}"
    @paste_entry = PasteEntry[paste_id]
    @paste_entry.filter = (Filter.find(:filter_method => @paste_entry.channel) || Filter.find(:filter_name => "Plain Text")) if @paste_entry.filter.nil?
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

  def view_annotation(annotation_id, filename)
    @annotation = Annotation[annotation_id]
    raise "Annotation not found" if @annotation.nil?
    respond(@annotation.paste_body.to_s, 200, "Content-Type" => "text/plain")
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
