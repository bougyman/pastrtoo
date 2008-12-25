# This class will allow rails to speak through the Autumn bot instance
require "drb"
require "set"
class PastrDrb
  DEFAULT_NETWORK = 'Efnet'

  def self.say(message, target, network = nil, sender = nil)
    p = self.new
    told = p.say(message, target, network, sender)
    p.drb = nil
    told
  end

  def initialize(*opts)
    @drb_uri = "druby://127.0.0.1:9099"
  end

  def say(message, target, network = nil, sender = nil)
    network ||= DEFAULT_NETWORK
    result = nil
    stem = stems.detect { |s| s.options[:server_id] == network.to_s }
    return "Invalid Network: #{network}" if stem.nil?
    if target.match(/^[#&+]/)
      if sender
        return "Sender nickname #{sender} not found in #{target}" unless check_target(stem, sender, target)
      else
        return "Pastr doesn't seem to be in #{target} currently" unless stem.channel_members.keys.include?(target)
      end
      result = stem.message message, target
    else
      return "No network found for #{target}" if stem.nil?
      return "#{target} not found on #{network}" unless known_nicks(stem).include?(target)
      result = stem.message message, target
    end
    result
  end

  def known_nicks(stem)
    stem.channel_members.values.map { |v| v.keys }.flatten.uniq
  end

  def check_target(stem, nickname, channel = nil)
    if channel.nil?
      return false unless known_nicks(stem).include?(nickname)
    else
      stem.channel_members.keys.include?(channel) and stem.channel_members[channel].keys.include?(nickname)
    end
  end

  def stems
    @stems ||= drb.stems
  end

  def drb=(other)
    return unless other.nil?
    DRb.stop_service unless DRb.thread.nil?
    @drb = nil
  end

  def drb
    DRb.start_service if DRb.thread.nil?
    @drb ||= DRbObject.new_with_uri(@drb_uri)
  end
end
