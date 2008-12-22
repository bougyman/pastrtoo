# This class will allow rails to speak through the Autumn bot instance
require "drb"
class PastrDrb
  def self.say(message, target)
    drb = get_drb
    result = drb.stems.message message, target
    drb = nil
    result
  end

  def self.get_drb
    drb = DRbObject.new_with_uri("druby://127.0.0.1:9099")
  end
end
