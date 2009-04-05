require "optparse"
require "ostruct"
class PastrIt
  PasteLink = "http://pastr.it/new"
  attr_reader :opts, :o
  def initialize(args = nil)
    @o = OpenStruct.new(:network => "Freenode", :username => ENV["USER"])
    @args = args || ARGV
  end

  def parse_args
    @opts = OptionParser.new
    @opts.banner = "\nUsage: pastr-it [options]"
    @opts.on("-c", "--channel CHANNEL", "IRC Channel for this Pastr (required)") { |foo| @o.channel = foo }
    @opts.on("-n", "--network NETWORK", "IRC Network for this Pastr (Default #{@o.network}") { |foo| @o.network = foo }
    @opts.on("-l", "--language LANGUAGE", "Language to use for syntax highlighting") { |foo| @o.language = foo }
    @opts.on("-t", "--title TITLE", "Title of this paste (Default 'Pastr by #{@o.username}')") { |foo| @o.title = foo }
    @opts.on("-f", "--file FILENAME", "Read paste_body from FILENAME (otherwise reads from stdin)") { |foo| @o.filename = foo }

    @opts.on("-u", "--username USERNAME", "Your username (Default #{@o.username}") { |foo| @o.username = foo }
    @opts.on_tail("-h", "--help", "Show this message") do
      puts @opts
      exit 
    end   
    @opts.parse!(@args)
    raise 'Must supply a channel' unless @o.channel
  end

  def pastr_it
    if File.file?(netrc = ENV["HOME"] + "/.netrc")
      if p_auth = File.readlines(netrc).detect { |line| line.match(/^machine\s+pastr\.it/) }
        @o.username, @o.password = p_auth.split(/\s+/,4)[2 .. 3]
      end
    end
    unless @o.password
      print "Enter Password: "
      system("stty -echo")
      @o.password = $stdin.readline.chomp
      system("stty echo")
      print "\n"
    end
    form = {'network' => @o.network, 'channel' => @o.channel, 'paste_body' => paste_body}
    form["title"] = @o.title if @o.title
    form["language"] = @o.language if @o.language
    require "net/http"
    require "uri"
    url = URI.parse(PasteLink)
    req = Net::HTTP::Post.new(url.path)
    req.basic_auth @o.username, @o.password
    req.set_form_data(form)
    proxy = URI.parse(ENV["HTTP_PROXY"].to_s)
    res = Net::HTTP::Proxy(proxy.host, proxy.port).start(url.host, url.port) { |http| http.request(req) }
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      puts "OK: #{res.body}"
    else
      res.error!
    end
  rescue
    system("stty echo")
    raise
  ensure
    system("stty echo")
  end

  def paste_body
    return @paste_body if @paste_body
    if @o.filename
      raise "#{@o.filename} does not exist or is not readable" unless File.file?(@o.filename)
      @paste_body = File.read(@o.filename)
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
