require File.expand_path(File.join(File.dirname(__FILE__),  "..", "model", "init.rb"))

require "digest/md5"
require "drb"
require "drb/ssl"
PASTR_SOCKET = 'druby://127.0.0.1:9099'

class Controller < Autumn::Leaf

  before_filter :authenticate, :only => [ :hit, :reload, :quit ]
  
  def about_command(stem, sender, reply_to, msg)
    "Pastr allows you to paste into a syntax highlighted entry!"
  end

  def help_command(stem, sender, reply_to, msg)
    "type .hitme<enter> in a channel and i'll message you a paste link.  You paste there and it tells the channel"
  end

  def hello_command(stem, sender, reply_to, msg)
    "Hi, #{sender[:nick]}"
  end

# {{{ Public Methods, these are what we publish
  def hitme_command(stem, sender, reply_to, msg)
    #stem.message "Hitting #{sender[:nick]}"
    paster = ::Paster[:nickname => sender[:nick]] || ::Paster.create(:nickname => sender[:nick])
    #paste_title = params[:title].kind_of?(Array) ? params[:title].join(" ") : "Pastr by #{m.sourcenick}"
    paste_title = "Pastr by #{sender[:nick]}"
    salt = 'hard_to_cr4ck'
    key = "-" + ::Digest::MD5::hexdigest(salt + ::Time.now.to_i.to_s).to_s[0,8]
    channel = reply_to
    paste_entry = ::PasteEntry.create(:network => stem.options[:server_id], :paster_id => paster.id, :reply_to => PASTR_SOCKET, :title => paste_title, :channel => channel, :paste_key => key)
    stem.message "Paste to http://paste.linuxhelp.tv/#{paste_entry.id}/#{key}", sender[:nick]
    nil
  end

  def hit_command(stem, sender, reply_to, msg)
    nick = msg
    paster = ::Paster[:nickname => nick] || ::Paster.create(:nickname => nick)
    paste_title = "Pastr by #{paster.nickname}"
    salt = 'hard_to_cr4ck'
    key = '-' + ::Digest::MD5::hexdigest(salt + ::Time.now.to_i.to_s).to_s[0,8]
    channel = reply_to
    paste_entry = ::PasteEntry.create(:network => stem.options[:server_id], :paster_id => paster.id, :reply_to => PASTR_SOCKET, :title => paste_title, :channel => channel, :paste_key => key)
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
  
  def authenticate_filter(stem, channel, sender, command, msg, opts)
    # Returns true if the sender has any of the privileges listed below
    not ([ :operator, :admin, :founder, :channel_owner ] & [ stem.privilege(channel, sender) ].flatten).empty?
  end

end

