class PasteEntry < Sequel::Model
  many_to_one :paster
  many_to_one :filter
  one_to_many :annotations

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
    require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "pastr_drb"))
    PastrDrb.say("#{paster.nickname} pasted http://paste.linuxhelp.tv/#{id} (#{title || 'Untitled'}), #{paste_body.split(/\n/).size} lines of #{filter.filter_name}", channel)
  end

end
