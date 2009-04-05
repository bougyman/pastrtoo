# Default url mappings are:
#  a controller called Main is mapped on the root of the site: /
#  a controller called Something is mapped on: /something
# If you want to override this, add a line like this inside the class
#  map '/otherurl'
# this will force the controller to be mounted on: /otherurl

Ramaze::Route["/admin"] = "/"

class MainController < Controller
  def error
    #require "pp"
    require "ipaddr"
    debug_net = IPAddr.new("192.168.6.0/24")
    client_addr = IPAddr.new(request.env["REMOTE_ADDR"])
    unless debug_net.include?(client_addr)
      @title = "There was a pastr error!"
      flash[:ERRORS] = "The error for your request from #{client_addr} has been logged"
      @content = render_template("index.xhtml")
      page = render_template("page.xhtml")
      respond(page)
    else
      super
    end
  end

  # the index action is called automatically when no other action is specified
  def index
    #respond("<pre>" + request.env.inspect + "</pre>")
    @title = "Welcome to Pastr!"
  end

  def new(network = nil, channel = nil, language = nil, title = nil)
    require "lib/pastr_drb"
    @current_networks = (pdb = PastrDrb.new).networks
    @network_name = network || request["network"]
    @current_channels = pdb[@network_name].channels.to_a if @current_networks.include?(@network_name)
    if @current_channels and @channel_name = (channel || request["channel"])
      @channel_name.sub!(/^_/,"#")
      if @channel_name == request.env["REMOTE_USER"] || @current_channels.include?(@channel_name)
        language ||= request["language"]
        @filter_id = Filter.filter(:filter_name.ilike language).or(:filter_method.ilike language).first if language
        @pastr = PasteEntry.create(:paster_id => Paster.find_or_create(:nickname => request.env["REMOTE_USER"]).id,
                                   :network => @network_name,
                                   :channel => @channel_name,
                                   :title => title || request["title"],
                                   :filter => @filter_id || Filter.id_for(@channel_name, @network_name))
        if request["paste_body"]
          Ramaze::Log.info("Paste body sent, saving")
          @pastr.update_with_params(:paste_body => request["paste_body"])
          redirect @pastr.view_link
        else
          redirect @pastr.paste_link
        end
      end
    end
  end

end
