# Controller for the LogBot leaf.
require "date2"
require "fileutils"
require "pathname"

class Controller < Autumn::Leaf
  @@log_directory = File.join(ENV["HOME"], "chatlogs")
  
  # Typing "!about" displays some basic information about this leaf.
  
  def about_command(stem, sender, reply_to, msg)
    # This method renders the file "about.txt.erb"
  end
  
  def rand_command(stem, sender, reply_to, msg)
    rand(100).to_s
  end

  def someone_did_join_channel(stem, person, channel)
    message = "#{person[:nick]} joined #{channel} on #{stem.options[:server_id]}"
    log_channel(channel, stem, message)
  end

  def someone_did_leave_channel(stem, person, channel)
    puts "Someone left: #{person.inspect} #{channel}"
    message = "#{person[:nick]} left #{channel} on #{stem.options[:server_id]}"
    log_channel(channel, stem, message)
  end

  def did_receive_channel_message(stem, sender, channel, msg)
    nick = sender[:nick] == "bougyman" ? "bougy" : sender[:nick]
    message = "<#{nick}> #{msg}"
    log_channel(channel, stem, message)
  end

  def last_command(stem, sender, channel, msg)
    found = nil
    begin
      regex = /#{msg.strip}/
    rescue RegexpError, SyntaxError => ex
      return "Error: #{ex}"
    end
    stem.message("Searching for #{regex}", channel)
    channel_files(fq(channel, stem)).detect do |log|
      log.readlines.reverse.detect do |message| 
        if message.match(regex)
          found = message
          true
        else
          false
        end
      end 
    end
    found ? found.to_s : "Nothing found matching #{msg}"
  end

  private

  def fq(channel, stem)
    [channel, stem.options[:server_id]].join("-")
  end

  def channel_files(channel)
    log_dir = Pathname.new(@@log_directory).join(channel)
    return [] unless log_dir.directory?
    log_dir.children.select { |l| l.to_s.match(/\.log$/) }.sort { |a,b| b.to_s <=> a.to_s }
  end

  def channel_file(channel, now = DateTime.now)
    today = now.strftime("%Y-%m-%d")
    log_dir = Pathname.new(@@log_directory).join(channel)
    FileUtils.mkpath(log_dir) unless log_dir.directory?
    log_dir.join("#{today}.log").expand_path
  end

  def log_channel(channel, stem, message)
    full_channel = fq(channel, stem)
    if @options[:log_channels].kind_of?(Array) and @options[:log_channels].include?(full_channel)
      now = DateTime.now
      File.open(channel_file(full_channel, now), "a+") do |ch_log|
        ch_log.puts "#{now.strftime("%H:%M:%S")}: #{message}"
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
