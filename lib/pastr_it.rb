require "optparse"
class PastrIt
  VERSION = '0.1.4'
  REALM = 'Pastr Registered User'
  PasteLink = "http://pastr.it/new"
  attr_accessor :password, :filename, :title, :network, :channel, :language, :username
  def initialize(args = nil)
    @network, @username = "Freenode", ENV["USER"]
    @args = args || ARGV
    parse_args
  end

  def parse_args
    return @opts if @opts
    @opts = OptionParser.new
    @opts.banner = "\nUsage: pastr-it [options] FILE\n"
    @opts.on("-u", "--username USERNAME", "Your username (Default: #{@username})") { |foo| @username = foo }
    @opts.on("-c", "--channel CHANNEL", "IRC Channel for this Pastr (Default: same as username)") { |foo| @channel = foo }
    @opts.separator "\tWhen using your username as the channel argument, the paste will be private"
    @opts.on("-n", "--network NETWORK", "IRC Network for this Pastr (Default: #{network})") { |foo| @network = foo }
    @opts.on("-l", "--language LANGUAGE", "Language to use for syntax highlighting") { |foo| @language = foo }
    @opts.on("-t", "--title TITLE", "Title of this paste (Default: Filename or 'Pastr by #{username}')") { |foo| @title = foo }
    #@opts.on("-f", "--file FILENAME", "Read paste_body from FILENAME (otherwise reads from stdin)") { |foo| @filename = foo }
    @opts.separator "\tTo paste from STDIN (instead of a file), leave off FILE, and you'll need to auth with a ~/.netrc"

    @opts.on_tail("-h", "--help", "Show this message") do
      puts @opts
      exit 
    end   
    @opts.parse!(@args)
    @filename = ARGV.shift if ARGV.size == 1 and File.file?(ARGV.first)
    @title ||= File.basename(@filename) if @filename
    @channel ||= @username
    if @filename.nil? and STDIN.isatty
      $stderr.puts "No Input on STDIN and no filename given, what am I supposed to paste?" 
      exit 1
    end
  end

  def pastr_it
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
        end
      else
        STDERR.puts "Error: STDIN is not a tty (you supplied your paste through STDIN instead of a FILENAME)"
        STDERR.puts "Piping only works when using a ~/.netrc to supply login info, as the Password prompt needs STDIN to be a tty"
        exit 1
      end
    end 
    form = {'network' => network, 'channel' => channel, 'paste_body' => paste_body}
    form["title"] = title if title
    form["language"] = language if language
    require "httpclient"
    client = HTTPClient.new(ENV["HTTP_PROXY"])
    # Have to do this to get a valid cookie with the server before we auth (lame)
    res = client.get("http://pastr.it")
    if res.status != 200
      puts "Cannot access http://pastr.it. Webserver said Status: #{res.status} -> #{res.reason}"
      exit 1
    end
    # Now set auth and post
    client.set_auth(PasteLink, username.strip, password.strip)
    res = client.post(PasteLink, form)
    if res.status != 200
      puts "An error occurred posting to#{PasteLink}. Webserver said Status: #{res.status} -> #{res.reason}"
      exit 1
    end
    puts res.content
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

  def self.pastr_it(args)
    me = PastrIt.new(args)
    me.parse_args
    me.pastr_it
  end
end
#:et;ts=2;sw=2;foldmethod=indent
