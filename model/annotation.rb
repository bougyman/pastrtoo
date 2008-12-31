class Annotation < Sequel::Model
  many_to_one :paste_entry
  many_to_one :filter
  many_to_one :paster

  after_create :notify_channel
  validates_presence_of :paster_id, :paste_entry_id

  def text
    self.paste_body
  end

  def syntax
    self.filter ? self.filter.filter_method : "plaintext"
  end

  def network
    paste_entry.network
  end

  def channel
    paste_entry.channel
  end

  def sections
    @sections ||= paste_body.split(/^(##\s+\w.*?)(?:\r?\n|$)/sm).map { |sec| sec.strip }
  end

  private
  def notify_channel
    require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "pastr_drb")) unless Object.const_defined?("PastrDrb")
    message = "#{paster.nickname} annotated http://paste.linuxhelp.tv/#{paste_entry.id}-#{paste_entry.annotations.size} (#{title || 'Untitled'}), with #{paste_body.split(/\n/).size} lines of #{filter.filter_name}"
    PastrDrb.say(message, channel, network, paster.nickname)
  end
end
