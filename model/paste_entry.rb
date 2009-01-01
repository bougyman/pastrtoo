class PasteEntry < Sequel::Model
  many_to_one :paster
  many_to_one :filter
  one_to_many :annotations, :order => :updated_at

  after_update :notify_channel
  validates_presence_of :paster_id

  def text
    self.paste_body
  end

  def number_of_lines
    "#{(n_lines = text.split(/n/).size)} line#{n_lines == 1 ? "" : "s"}"
  end

  def syntax
    self.filter ? self.filter.filter_method : "plaintext"
  end

  def sections
    @sections ||= paste_body.split(/^(##\s+\w.*?)(?:\r?\n|$)/sm).map { |sec| sec.strip }
  end

  def annotations?
    annotations.size > 0 ? true : false
  end

  def annotation_count
    "#{a_size = annotations.size} annotation#{a_size == 1 ? "" : "s"}"
  end

  def to_s
    "#{title.rstrip}: #{number_of_lines} of #{filter.filter_name} by #{paster.nickname} - #{annotation_count}"
  end

  private
  def notify_channel
    return unless channel.match(/^[#&+]/)
    require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "pastr_drb")) unless Object.const_defined?("PastrDrb")
    message = "#{paster.nickname} pasted http://paste.linuxhelp.tv/#{id} (#{title || 'Untitled'}), #{number_of_lines} lines of #{filter.filter_name}"
    PastrDrb.say(message, channel, network)
  end

end
