require "optparse"
class PastrIt
  VERSION = '0.1.7'
  REALM = 'Pastr Registered User'
  PastrHome = "http://pastr.it"
  PastrNew  = "%s/%s" % [PastrHome, :new]
  PastrEdit = "%s/%s" % [PastrHome, :edit]
  PastrNote = "%s/%s" % [PastrHome, :annotate]
  attr_accessor :password, :filename, :title, :network, :channel, :language, :username, :annotate_id, :pastr_id, :no_body
  def initialize(args = nil)
    @network, @username = "Freenode", ENV["USER"]
    @args = args || ARGV
    parse_args
  end

  def self.pastr_it(args)
    me = PastrIt.new(args)
    me.parse_args
    if me.annotate_id
      me.annotate_it
    elsif me.pastr_id
      me.edit_it
    else
      me.pastr_it
    end
  end

  def parse_args
    return @opts if @opts
    @opts = OptionParser.new
    @opts.banner = "\nUsage: pastr-it [options] FILE"

    @opts.separator "--- Common Pastr Options"
    @opts.separator " To paste from STDIN (instead of a file), leave off FILE, and you'll need to auth with a ~/.netrc"
    @opts.on("-u", "--username USERNAME", "Your username (Default: #{@username})") { |foo| @username = foo }
    @opts.on("-c", "--channel CHANNEL", "IRC Channel for this Pastr (Default: same as username)") { |foo| @channel = foo }
    @opts.separator "\tWhen using your username as the channel argument, the paste will be private"
    @opts.on("-n", "--network NETWORK", "IRC Network for this Pastr (Default: #{network})") { |foo| @network = foo }
    @opts.on("-l", "--language LANGUAGE", "Language to use for syntax highlighting") { |foo| @language = foo }
    @opts.on("-t", "--title TITLE", "Title of this paste (Default: Filename or 'Pastr by #{username}')") { |foo| @title = foo }

    @opts.separator "--- Editing"
    @opts.on("-e", "--edit PASTR_ID", "ID Of paste to edit (instead of making a new paste)") { |foo| @pastr_id = foo }
    @opts.on("-N", "--no-body", "Just edit metadata (channel, language, etc), not the paste body") { |foo| @no_body = true }

    @opts.separator "--- Annotate"
    @opts.on("-a", "--annotate PASTR_ID", "ID Of paste to annotate (incompatible with -e/--edit.  -n/--network, and -c/--channel ignored.)") { |foo| @annotate_id = foo }

    @opts.separator "--- Informational"
    @opts.on("-L", "--list", "List supported languages") { |foo| @list_langs = true }
    @opts.on("-v", "--version", "Print pastr version") { |foo| @version_only = true }
    @opts.on_tail("-h", "--help", "Show this message") do
      puts @opts
      exit 
    end   
    @opts.parse!(@args)

    if @list_langs
      puts http_request(:url => "http://pastr.it/languages").content
      exit
    elsif @version_only
      puts "pastr-it for http://pastr.it - Version: #{PastrIt::VERSION}"
      exit
    end

    @filename = ARGV.shift if ARGV.size == 1 and File.file?(ARGV.first)
    @title ||= File.basename(@filename) if @filename
    @channel ||= @username
    if @filename.nil? and STDIN.isatty
      $stderr.puts "No Input on STDIN and no filename given, what am I supposed to paste?" 
      exit 1
    end unless @pastr_id
  end

  def annotate_it
    form = {'paste_body' => paste_body}
    form["title"] = title if title
    form["language"] = language if language
    puts http_request(:form => {"annotation_#{@annotate_id}" => form}, :url => PastrNote).content
  end

  def edit_it
    form = {'network' => network, 'channel' => channel, 'paste_body' => paste_body}
    form = {}
    form['network']     = network if network
    form['channel']     = channel if channel
    form["title"]       = title if title
    form["language"]    = language if language
    form['paste_body']  = paste_body unless no_body
    puts http_request(:form => {"pastr_#{@pastr_id}" => form}, :url => PastrEdit).content
  end

  def pastr_it
    form = {'network' => network, 'channel' => channel, 'paste_body' => paste_body}
    form["title"] = title if title
    form["language"] = language if language
    puts http_request(:form => form).content
  end

  private
  def http_request(args)
    form = args[:form] || nil
    url = args[:url] || PastrNew
    auth = args[:auth] || true
    require "httpclient"
    if auth
      check_netrc
      check_password
    end
    client = HTTPClient.new(ENV["HTTP_PROXY"] ? ENV["HTTP_PROXY"] : ENV["http_proxy"])
    # Have to do this to get a valid cookie with the server before we auth (lame)
    res = client.get(PastrHome)
    if res.status != 200
      puts "Cannot access #{PastrHome}. Webserver said Status: #{res.status} -> #{res.reason}"
      exit 1
    end
    if form
      # Now set auth and post
      client.set_auth(url, username.strip, password.strip) if auth
      res = client.post(url, form)
    else
      # Or set auth and get
      client.set_auth(url, username.strip, password.strip) if auth
      res = client.get(url)
    end
    if res.status != 200
      puts "An error occurred posting to #{url}. Webserver said Status: #{res.status} -> #{res.reason}"
      exit 1
    end
    res
  end

  def check_netrc
    if File.file?(netrc = ENV["HOME"] + "/.netrc")
      if p_auth = File.readlines(netrc).detect { |line| line.match(/^machine\s+pastr\.it/) }
        if uname = p_auth.match(/login\s+(\S+)/)
          unless @username != ENV["USER"]
            puts "Using username from ~/.netrc" if $DEBUG
            @username = uname[1]
          end
        end
        if pwd = p_auth.match(/password\s+(\S+)/) and uname[1] == @username
          unless @password
            puts "Using password from ~/.netrc" if $DEBUG
            @password = pwd[1]
          end
        end
      end
    end
  end

  def check_password
    unless @password
      if STDIN.isatty
        begin
          print "Enter Password: "
          system("stty -echo")
          @password = $stdin.readline.chomp
          system("stty echo")
          print "\n"
        rescue
          system("stty echo")
        ensure
          system("stty echo")
        end
      else
        STDERR.puts "Error: STDIN is not a tty (you supplied your paste through STDIN instead of a FILENAME)"
        STDERR.puts "Piping only works when using a ~/.netrc to supply login info, as the Password prompt needs STDIN to be a tty"
        exit 1
      end
    end 
  end

  def paste_body
    return @paste_body if @paste_body
    if filename
      raise "#{filename} does not exist or is not readable" unless File.file?(filename)
      @paste_body = File.read(filename)
    else
      @paste_body = $stdin.read
    end
  end

end
#:et;ts=2;sw=2;foldmethod=indent
