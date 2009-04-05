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

  def new
    require "lib/pastr_drb"
    @current_networks = (pdb = PastrDrb.new).networks
    @network_name = request["network"]
    @current_channels = pdb[@network_name].channels.to_a if @current_networks.include?(@network_name)
  end

  def create
    "Creating new pastr (once bougy tells me how to do so)"
  end

  # the string returned at the end of the function is used as the html body
  # if there is no template for the action. if there is a template, the string
  # is silently ignored
  def notemplate
    "there is no 'notemplate.xhtml' associated with this action"
  end
end
