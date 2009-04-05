require File.join(File.dirname(__FILE__), "paste_section") unless Object.const_defined?("PasteSection")
class PasteEntry < Sequel::Model
  include PasteSection::SectionHelper
  many_to_one :paster
  many_to_one :filter
  one_to_many :annotations, :order => :updated_at

  after_update :notify_channel
  validates_presence_of :paster_id
  before_save :check_privacy

  def text
    self.paste_body
  end

  def number_of_lines
    "#{(n_lines = text.split(/\n/).size)} line#{n_lines == 1 ? "" : "s"}"
  end

  def syntax
    self.filter ? self.filter.filter_method : "plaintext"
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

  def check_privacy
    return true if self.private
    # If not in a public channel, mark this as private
    self.private = true unless channel.match(/^[+&#]/)
    # Always return true
    true
  end

  def notify_channel
    return unless channel.match(/^[#&+]/)
    require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "pastr_drb")) unless Object.const_defined?("PastrDrb")
    message = "#{paster.nickname} pasted http://pastr.it/#{id} (#{title || 'Untitled'}), #{number_of_lines} of #{filter.filter_name}"
    PastrDrb.say(message, channel, network)
  end

end
