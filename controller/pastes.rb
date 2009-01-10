# Default url mappings are:
#  a controller called Main is mapped on the root of the site: /
#  a controller called Something is mapped on: /something
# If you want to override this, add a line like this inside the class
#  map '/otherurl'
# this will force the controller to be mounted on: /otherurl
Ramaze::Route[ %r!^/(\d+)/(\w.*)$! ] = "/pastes/view/%d/%s"
Ramaze::Route[ %r!^/(\d+)$! ] = "/pastes/view/%d"
Ramaze::Route[ %r!^/(\d+)/(-\w+)$! ] = "/pastes/edit/%d/%s"
Ramaze::Route[ %r!^/by/(.*)$! ] = "/pastes/by/%s"
class PastesController < Controller
  helper :paginate
  # the index action is called automatically when no other action is specified
  def index(paste_id = nil)
    if paste_id and paste_id.to_s.match(/\d+/)
      redirect(R(:view, paste_id))
    end
    @title = "Recent Pastes"
    paste_entry_data = PasteEntry.order(:id.desc).filter("paste_body is not null and private is false")
    @paste_entries = paginate(paste_entry_data, :limit => 25)
  end

  def by(*args)
    resp_error("Args must be in the form /filter/criteria (/language/ruby, /paster/bougyman, /channel/ruby/network/freenode, etc)") unless args.size % 2 == 0 
    dataset = args.each_slice(2).inject PasteEntry.order(:id.desc).filter("paste_body is not null and private is false") do |ds, sli|
      filter, criteria = sli
      case filter
      when "language"
        filter = Filter.find(:filter_method => criteria)
        resp_error("Filter #{criteria} not found") if filter.nil?
        ds.filter(:filter_id => filter.id)
      when /paster|nick(?:name)?/
        paster = Paster.find(:nickname => criteria)
        resp_error("Paster #{criteria} not found") if paster.nil?
        ds.filter(:paster_id => paster.id)
      when "channel"
        ds.filter(:channel => "#" + criteria.to_s)
      when "network"
        ds.filter(:network => criteria.to_s.capitalize)
      when /subject|title/
        ds.filter(:title.like(/#{criteria}/i)) 
      else
        resp_error "Invalid filter chosen #{filter}"
      end
    end
    resp_error("Your search returned 0 results: #{args.join('/')}") if dataset.size == 0
    @title = "Pastes matching #{args.join('/')}"
    @paste_entries = paginate(dataset, :limit => 25)
    render_template("index.xhtml")
  end

  def common_annotate(paste_id)
    @title = "Annotating Paste #{paste_id}"
    @annotation = Annotation.new
    @cookie_nick = request.cookies["pastr_nickname"]
    @captcha = CAPTCHA::Web.new(:image_dir => File.join(File.dirname(__FILE__), "..", "public/img"), :font => "/usr/share/fonts/truetype/ttf-bitstream-vera/Vera.ttf")
    @captcha.image
    @captcha.clean
  end
  private :common_annotate

  def annotate(paste_id)
    require "captcha"
    @paste_entry = PasteEntry[paste_id]
    @annotation = Annotation.new

    paste_not_found(paste_id) if @paste_entry.nil?
    common_annotate(paste_id)
  end

  def add_annotation(paste_id)
    require "captcha"
    captcha_digest = request["captcha_digest"]
    captcha_key    = request["captcha_key"]
    @paste_entry = PasteEntry[paste_id]
    paste_not_found(paste_id) if @paste_entry.nil?
    @annotation = Annotation.new(request["annotation"])
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
      response.set_cookie("pastr_nickname", :path => "/", :value => nickname, :expires => Time.now + (3600 * 24 * 365)) unless request.cookies["pastr_nickname"] == nickname
      annotation = Annotation.create({:channel => @paste_entry.channel, :paste_entry_id => paste_id, :paster_id => paster.id}.merge(request["annotation"]))
      if annotation.nil?
        flash[:ERRORS] = "Failed to annotate!"
        common_annotate(paste_id)
        render_template("annotate.haml")
      else
        @title = "Annotation #{@paste_entry.annotations.size} created"
        require "coderay" unless Object.const_defined?("CodeRay")
        require "uv" unless Object.const_defined?("Uv")
        render_template("view.haml")
      end
    end
  end

  def edit(paste_id, key = nil)
    @title = "Editing Paste #{paste_id}"
    @paste_entry = PasteEntry[paste_id]
    paste_not_found(paste_id) if @paste_entry.nil?
    @paste_entry.filter = (Filter.find(:filter_method => @paste_entry.channel) || Filter.find(:filter_name => "Plain Text")) if @paste_entry.filter.nil?
    unless key == @paste_entry.paste_key
      flash[:ERRORS] = {"Key" => "does not match paste key"}
      redirect R(PastesController)
    else
      render_template("edit.haml")
    end
  end

  def channel(channel, network = nil)
    @title = "Pastes for #{channel}"
    @paste_entries = PasteEntry.order(:id.desc).filter("title is not null and paste_body is not null").filter(:channel => "#" + channel)
    @paste_entries = @paste_entries.filter(:network => network.capitalize) unless network.nil?
    @paste_entries = paginate(@paste_entries, :limit => 25)
    render_template("index.xhtml")
  end

  def view(paste_id, filename = nil)
    @paste_entry = PasteEntry[paste_id]
    paste_not_found(paste_id) if @paste_entry.nil?
    if filename
      respond(@paste_entry.paste_body.to_s, 200, 'Content-Type' => "text/plain")
    else
      @title = @paste_entry.title || "Paste number #{paste_id}"
    end
    require "coderay" unless Object.const_defined?("CodeRay")
    require "uv" unless Object.const_defined?("Uv")
    render_template("view.haml")
  end

  def view_annotation(annotation_id, filename)
    @annotation = Annotation[annotation_id]
    raise "Annotation not found" if @annotation.nil?
    respond(@annotation.paste_body.to_s, 200, "Content-Type" => "text/plain")
  end

  def update(paste_id, key)
    @paste_entry = PasteEntry[paste_id]
    paste_not_found(paste_id) if @paste_entry.nil?
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

  private

  def paste_not_found(paste_id)
    resp_error("Paste #{paste_id} not found")
  end

  def resp_error(message)
    @title = "An Error Has Occured"
    @content = h message
    respond(render_template("page.haml"))
  end

end
