# Controller and model for the Insulter leaf; maintains the list of insult
# substrings and chooses from them randomly.
require "uri"
require "open-uri"
require "json"

class Controller < Autumn::Leaf
  
  def a_command(stem, sender, reply_to, msg)
    if msg.nil?
      render :help
    else 
      search msg 
    end
  end
  
  # Displays information about the leaf.
  
  def help_command(stem, sender, reply_to, msg)
    usage
  end


  def about_command(stem, sender, reply_to, msg)
    usage
  end
  
  private
  
  def usage
    "?a <search> search archlinux sites"
  end
  
  GOOGLE_URI = "https://www.googleapis.com/customsearch/v1?key=AIzaSyAtRJ-svZdX8ocl72VYYkpw1iRtvcdsPyA&cx=003826523042256318919:fnvg_soniec&alt=json"
  def search(query)
    res = JSON.parse(open("%s&q=%s" % [GOOGLE_URI, URI.escape(query)]).read)
    ours = res["items"][0 .. 2]
    ours.map { |n| "%s - %s" % [ n['link'], n['title'] ] }.join(" | ")
  rescue
    "Woops, something went wrong"
  end
end

                          
