# Controller and model for the Insulter leaf; maintains the list of insult
# substrings and chooses from them randomly.
require "uri"
require "open-uri"
require "json"

class Controller < Autumn::Leaf
  
  # Insults the unfortunate argument of this command.
  
  def g_command(stem, sender, reply_to, msg)
    if msg.nil?
      render :help
    else 
      search msg 
    end
  end
  
  def help_command(stem, sender, reply_to, msg)
    usage
  end
  # Displays information about the leaf.
  
  def about_command(stem, sender, reply_to, msg)
    usage
  end
  
  private

  def usage
    "?g <search> search google"
  end
  
  GOOGLE_URI = "https://www.googleapis.com/customsearch/v1?key=AIzaSyCL-fXkVzC7yQDhkK2ppCZGhuZgecQyNFk&cx=003826523042256318919:zjbx0iridus&alt=json"
  def search(query)
    res = JSON.parse(open("%s&q=%s" % [GOOGLE_URI, URI.escape(query)]).read)
    ours = res["items"][0 .. 2]
    ours.map { |n| "%s - %s" % [ n['link'], n['title'] ] }.join(" | ")
  rescue
    "Woops, something went wrong"
  end
end
