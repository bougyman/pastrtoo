# Controller for the LogBot leaf.
require "date2"
require "fileutils"

class Controller < Autumn::Leaf
  @@log_directory = File.join(ENV["HOME"], "chatlogs")
  
  # Typing "!about" displays some basic information about this leaf.
  
  def about_command(stem, sender, reply_to, msg)
    # This method renders the file "about.txt.erb"
  end
  
  def someone_did_join_channel(stem, person, channel)
    message = "#{person[:nick]} joined #{channel} on #{stem.options[:server_id]}"
    log_channel(channel, stem, message)
  end

  def someone_did_leave_channel(stem, person, channel)
    message = "#{person[:nick]} left #{channel} on #{stem.options[:server_id]}"
    log_channel(channel, stem, message)
  end

  def did_receive_channel_message(stem, sender, channel, msg)
    nick = sender[:nick] == "bougyman" ? "bougy" : sender[:nick]
    message = "<#{nick}> #{msg}"
    log_channel(channel, stem, message)
  end

  private
  def log_channel(channel, stem, message)
    fq_channel = "#{channel}-#{stem.options[:server_id]}"
    if @options[:log_channels].kind_of?(Array) and @options[:log_channels].include?(fq_channel)
      today, now = Date.today.strftime("%Y-%m-%d"), DateTime.now.strftime("%H:%M:%S")
      log_dir = File.join(@@log_directory, fq_channel)
      FileUtils.mkpath(log_dir) unless File.directory?(log_dir)
      File.open(File.join(log_dir, "#{today}.log"), "a+") do |ch_log|
        ch_log.puts "#{now}: #{message}"
      end
    end
    say_channel(channel, stem, message)
  end

  def say_channel(channel, stem, message)
    fq_channel = "#{channel}-#{stem.options[:server_id]}"
    if @options[:clone_channels].kind_of?(Hash) and @options[:clone_channels].keys.include?(fq_channel)
      clone_stem, clone_chan = @options[:clone_channels][fq_channel].reverse.split("-",2).map(&:reverse)
      target_stem = stems.detect { |s| s.options[:server_id] == clone_stem }
      target_stem.message "#{message}", clone_chan
    end
  end
end
