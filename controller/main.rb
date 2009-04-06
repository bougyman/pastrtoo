# Default url mappings are:
#  a controller called Main is mapped on the root of the site: /
#  a controller called Something is mapped on: /something
# If you want to override this, add a line like this inside the class
#  map '/otherurl'
# this will force the controller to be mounted on: /otherurl

#Ramaze::Route["/admin"] = "/"
class MainController < Controller
  helper :httpdigest
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

  def httpdigest_failure
    respond("Fail!", 401)
  end
  # This method creates a new paste for authorized users, either
  # interactively or all-in-one-shot if you pass the proper url/request params.
  # http://pastr.it/NETWORK/CHANNEL/LANGUAGE/TITLE  
  # are the full URL options.  Note that CHANNEL maps /^_/ to # for convenience.
  # There is a command line interface giving access to all the available options
  # at http://pastr.it/admin, also an example of how to use curl.
  def new(network = nil, channel = nil, language = nil, title = nil)
    require "lib/pastr_it"
    username = httpdigest('new paste', PastrIt::REALM)
    require "lib/pastr_drb"
    @current_networks = (pdb = PastrDrb.new).networks
    @network_name = network || request["network"]
    # Set current channels if they passed a network name and we know about it (Freenode or Efnet)
    @current_channels = pdb[@network_name].channels.to_a if @current_networks.include?(@network_name)
    # Set @channel_name to the channel param if they passed it
    if @current_channels and @channel_name = (channel || request["channel"])
      # Modify _channel to #channel, convenience for passing channel names in the url
      @channel_name.sub!(/^_/,"#")
      # If the user wants a private paste (passes his username as @channel_name) ot
      # if we're in the channel they passed, go ahead the make the paste (or show the pasting form)
      if @channel_name == username || @current_channels.include?(@channel_name)
        language ||= request["language"]
        @filter_id = Filter.filter(:filter_name.ilike language).or(:filter_method.ilike language).first if language
        @pastr = PasteEntry.create(:paster => Paster.find_or_create(:nickname => username),
                                   :network => @network_name,
                                   :channel => @channel_name,
                                   :title => title || request["title"],
                                   :filter => @filter_id || Filter.filter_for(@channel_name, @network_name))
        if @pastr.paster.user.nil?
          (paster = @pastr.paster).user = @user
          paster.save
        end
        if request["paste_body"]
          # They passed a body, too, go ahead and save it, then show them the paste if they came interactively
          Ramaze::Log.info("Paste body sent, saving")
          @pastr.update_with_params(:paste_body => request["paste_body"])
          redirect @pastr.view_link if request[:showme].to_s == "true"
          respond(@pastr.view_link)
        else
          # No paste_body, Send them to the paste editing page
          redirect @pastr.paste_link
        end
      end
    end
  end

  def logout
    httpdigest_logout
    redirect_referer
  end

  protected
  def httpdigest_lookup_password(username)
    @user = User.find(:nickname => username)
    httpdigest_failure if @user.nil?
    @user.password
  end

end
