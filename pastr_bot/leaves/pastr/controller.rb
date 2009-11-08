require File.expand_path(File.join(File.dirname(__FILE__),  "..", "model", "init.rb"))
require File.expand_path(File.join(File.dirname(__FILE__),  "..", "lib", "pastrtoo.rb"))
require "pastrtoo/proverb"

require "digest/md5"
require "drb"
require "drb/ssl"
PASTR_SOCKET = 'druby://127.0.0.1:9099'

class Controller < Autumn::Leaf

  before_filter :authenticate, :only => [ :hit ]
  
  def about_command(stem, sender, reply_to, msg)
    "Pastr allows you to paste into a syntax highlighted entry! Type .help for more info, or check out http://pastr.it for the whole story."
  end

  def help_command(stem, sender, reply_to, msg)
    ".hitme <optional title> - in a channel and i'll message you a paste link.  You paste stuff at that link and it tells the channel about it\n" + 
    ".pastr <optional title> - exact same thing, more catchy name\n" +
    ".register <password> - register to be able to use http://pastr.it/admin functions (Freenode only, private message only)"
  end

  def hello_command(stem, sender, reply_to, msg)
    "Hi, #{sender[:nick]}"
  end

# {{{ Public Methods, these are what we publish
  def proverb_command(stem, sender, reply_to, msg)
    PastrToo::Proverb.sample(msg.to_s.size > 0 ? msg : nil)
  end

  def hitme_command(stem, sender, reply_to, msg)
    #stem.message "Hitting #{sender[:nick]}"
    paster = ::Paster.find_or_create(:nickname => sender[:nick])
    paste_title = msg.blank? ? "Pastr by #{sender[:nick]}" : msg
    paste_entry = ::PasteEntry.create(:network => stem.options[:server_id], :paster_id => paster.id, :reply_to => PASTR_SOCKET, :title => paste_title, :channel => reply_to, :filter_id => Filter.id_for(reply_to, stem.options[:server_id]))
    stem.message paste_entry.paste_link, sender[:nick]
    stem.message("Sent #{paste_entry.paste_link} to #{sender[:nick]}", reply_to) if reply_to.match(/lighttpd/)
    nil
  end

  def register_command(stem, sender, reply_to, msg)
    if stem.options[:server_id] != 'Freenode'
      ".register is only available on Freenode"
    else 
      if reply_to.match(/^[#&+]/)
        "Trying to register in public?  Why not just give everyone your social security number while you're at it?"
      elsif sender[:nick] == reply_to
        paster = ::Paster.find_or_create(:nickname => reply_to)
        user = User.find_or_create(:nickname => reply_to)
        user.set_pass(msg.strip)
        user.save
        paster.user = user
        paster.save
        "User #{reply_to} (uid #{user.id}): password set to #{msg.strip}"
      end
    end
  end

  def pastr_command(stem, sender, reply_to, msg)
    hitme_command(stem, sender, reply_to, msg)
  end

  def paste_command(stem, sender, reply_to, msg)
    hitme_command(stem, sender, reply_to, msg)
  end

  def hit_command(stem, sender, reply_to, msg)
    nick, title = msg.split(/\s+/,2)
    paster = ::Paster.find_or_create(:nickname => nick)
    paste_title = title.blank? ? "Pastr by #{paster.nickname}" : title
    paste_entry = ::PasteEntry.create(:network => stem.options[:server_id], :paster_id => paster.id, :reply_to => PASTR_SOCKET, :title => paste_title, :channel => reply_to, :filter_id => Filter.id_for(reply_to, stem.options[:server_id]))
    stem.message "Paste to #{paste_entry.paste_link}", nick
    stem.message "Sent #{paste_entry.paste_link} to #{nick}", sender[:nick]
    nil
  end

  def will_start_up
    here = PASTR_SOCKET
    DRb.start_service here, self
  end

  private
  
  def authenticate_filter(stem, channel, sender, command, msg, opts)
    # Returns true if the sender has any of the privileges listed below
    return true if sender[:nick].match(/^(?:darix|weigon|jvaughn|korozion|pgpkeys|napta|trey|icy|Pistos|bougyman|manveru|thedonvaughn|Death_Syn|kez)$/i)
    not ([ :operator, :admin, :founder, :channel_owner ] & [ stem.privilege(channel, sender) ].flatten).empty?
  end

end

