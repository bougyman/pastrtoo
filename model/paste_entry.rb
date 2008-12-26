class PasteEntry < Sequel::Model
  many_to_one :paster
  many_to_one :filter
  one_to_many :annotations, :order => :updated_at

  after_update :notify_channel
  validates_presence_of :paster_id

  def text
    self.paste_body
  end

  def syntax
    self.filter ? self.filter.filter_method : "plaintext"
  end

  private
  def notify_channel
    return unless channel.match(/^[#&+]/)
    require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "pastr_drb")) unless Object.const_defined?("PastrDrb")
    message = "#{paster.nickname} pasted http://paste.linuxhelp.tv/#{id} (#{title || 'Untitled'}), #{paste_body.split(/\n/).size} lines of #{filter.filter_name}"
    PastrDrb.say(message, channel, network)
  end

end
