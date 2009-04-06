require "optparse"
class PastrIt
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
    @opts.banner = "\nUsage: pastr-it [options]"
    @opts.on("-c", "--channel CHANNEL", "IRC Channel for this Pastr (required)") { |foo| @channel = foo }
    @opts.on("-n", "--network NETWORK", "IRC Network for this Pastr (Default #{network}") { |foo| @network = foo }
    @opts.on("-l", "--language LANGUAGE", "Language to use for syntax highlighting") { |foo| @language = foo }
    @opts.on("-t", "--title TITLE", "Title of this paste (Default 'Pastr by #{username}')") { |foo| @title = foo }
    @opts.on("-f", "--file FILENAME", "Read paste_body from FILENAME (otherwise reads from stdin)") { |foo| @filename = foo }

    @opts.on("-u", "--username USERNAME", "Your username (Default #{@username}") { |foo| @username = foo }
    @opts.on_tail("-h", "--help", "Show this message") do
      puts @opts
      exit 
    end   
    @opts.parse!(@args)
    raise 'Must supply a channel' unless @channel
  end

  def pastr_it
    if File.file?(netrc = ENV["HOME"] + "/.netrc")
      if p_auth = File.readlines(netrc).detect { |line| line.match(/^machine\s+pastr\.it/) }
        if match = p_auth.match(/login\s+(\S+)/)
          @username = match[1] unless @username
        end
        if match = p_auth.match(/password\s+(\S+)/)
          @password = match[1] unless @password
        end
      end
    end
    unless @password
      begin
        print "Enter Password: "
        system("stty -echo")
        @password = $stdin.readline.chomp
        system("stty echo")
        print "\n"
      rescue
        system("stty echo")
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
