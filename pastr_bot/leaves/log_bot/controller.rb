# Controller for the LogBot leaf.
require "date2"

class Controller < Autumn::Leaf
  @@log_directory = "/home/linuxhelp/pastrtoo/chatlogs"
  
  # Typing "!about" displays some basic information about this leaf.
  
  def about_command(stem, sender, reply_to, msg)
    # This method renders the file "about.txt.erb"
    "LogBot logs IRC"
  end

  def did_receive_channel_message(stem, sender, channel, msg)
    if @options[:log_channels].kind_of?(Array) and @options[:log_channels].include?(fq_channel = [channel, stem.options[:server_id]].join("-"))
      today, now = Date.today.strftime("%Y-%m-%d"), DateTime.now.strftime("%h:%M:%s")
      File.open(File.join(@@log_directory, "#{fq_channel}-#{today}.log"), "a+") do |ch_log|
        ch_log.puts "#{now}: <#{sender[:nick]}> #{msg}"
      end
    end
  end
end
