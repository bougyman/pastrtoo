require File.expand_path(File.join(File.dirname(__FILE__),  "..", "model", "init.rb"))

require "digest/md5"
require "drb"
require "drb/ssl"
PASTR_SOCKET = 'druby://127.0.0.1:9099'

class Controller < Autumn::Leaf

  before_filter :authenticate, :only => [ :hit, :reload, :quit ]
  
  def about_command(stem, sender, reply_to, msg)
    "Pastr allows you to paste into a syntax highlighted entry! Type .help for more info."
  end

  def help_command(stem, sender, reply_to, msg)
    ".hitme <optional title> - in a channel and i'll message you a paste link.  You paste stuff at that link and it tells the channel about it"
  end

  def hello_command(stem, sender, reply_to, msg)
    "Hi, #{sender[:nick]}"
  end

# {{{ Public Methods, these are what we publish
  def hitme_command(stem, sender, reply_to, msg)
    #stem.message "Hitting #{sender[:nick]}"
    paster = ::Paster[:nickname => sender[:nick]] || ::Paster.create(:nickname => sender[:nick])
    #paste_title = params[:title].kind_of?(Array) ? params[:title].join(" ") : "Pastr by #{m.sourcenick}"
    paste_title = msg.blank? ? "Pastr by #{sender[:nick]}" : msg
    salt = 'hard_to_cr4ck'
    key = "-" + ::Digest::MD5::hexdigest(salt + ::Time.now.to_i.to_s).to_s[0,8]
    channel = reply_to
    paste_entry = ::PasteEntry.create(:network => stem.options[:server_id], :paster_id => paster.id, :reply_to => PASTR_SOCKET, :title => paste_title, :channel => channel, :paste_key => key, :filter_id => filter_id_for(channel, stem.options[:server_id]))
    stem.message "Paste to http://paste.linuxhelp.tv/#{paste_entry.id}/#{key}", sender[:nick]
    nil
  end

  def pastr_command(stem, sender, reply_to, msg)
    hitme_command(stem, sender, reply_to, msg)
  end

  def hit_command(stem, sender, reply_to, msg)
    nick, title = msg.split(/\s+/,2)
    paster = ::Paster[:nickname => nick] || ::Paster.create(:nickname => nick)
    paste_title = title.blank? ? "Pastr by #{paster.nickname}" : title
    salt = 'hard_to_cr4ck'
    key = '-' + ::Digest::MD5::hexdigest(salt + ::Time.now.to_i.to_s).to_s[0,8]
    channel = reply_to
    paste_entry = ::PasteEntry.create(:network => stem.options[:server_id], :paster_id => paster.id, :reply_to => PASTR_SOCKET, :title => paste_title, :channel => channel, :paste_key => key, :filter_id => filter_id_for(channel, stem.options[:server_id]))
    paste_link = "http://paste.linuxhelp.tv/#{paste_entry.id}/#{paste_entry.paste_key}"
    stem.message "Paste to #{paste_link}", nick
    stem.message "Sent #{paste_link} to #{nick}", sender[:nick]
    nil
  end

  def will_start_up
    here = PASTR_SOCKET
    DRb.start_service here, self
  end

  private
  
  def filter_id_for(channel, network)
    f = filter_for(channel, network)
    f ? f.id : nil
  end

  def filter_for(channel, network)
    if pastr_channel = ::Channel.find(:name => channel, :network => network)
      pastr_channel.filter
    else
      Filter.find(:filter_method => "plaintext")
    end
  end

  def authenticate_filter(stem, channel, sender, command, msg, opts)
    # Returns true if the sender has any of the privileges listed below
    not ([ :operator, :admin, :founder, :channel_owner ] & [ stem.privilege(channel, sender) ].flatten).empty?
  end

end

