require File.join(File.dirname(__FILE__), "paste_section") unless Object.const_defined?("PasteSection")
class PasteEntry < Sequel::Model
  include PasteSection::SectionHelper
  many_to_one :paster
  many_to_one :filter
  one_to_many :annotations, :order => :updated_at

  after_update :notify_channel
  validates_presence_of :paster_id
  before_save :check_privacy
  before_save :key_check
  before_save :default_title

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

  def view_link
    @view_link ||= "http://pastr.it/#{id}"
  end

  def paste_link
    @paste_link ||= "%s/%s" % [view_link, paste_key]
  end

  private

  def check_privacy
    return true if self.private
    # If not in a public channel, mark this as private
    self.private = true unless channel.match(/^[+&#]/)
    # Always return true
    true
  end

  def default_title
    return true if self.title.to_s.size > 0
    self.title = "Pastr by #{paster.nickname}"
    true
  end

  def key_check
    return true if self.paste_key.to_s.match(/^-/)
    self.paste_key = '-' + ::Digest::MD5::hexdigest('hard_2_cr4ck' + ::Time.now.to_i.to_s).to_s[0,8]
    true
  end

  def notify_channel
    return unless channel.match(/^[#&+]/)
    require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "pastr_drb")) unless Object.const_defined?("PastrDrb")
    message = "#{paster.nickname} pasted http://pastr.it/#{id} (#{title || 'Untitled'}), #{number_of_lines} of #{filter.filter_name}"
    PastrDrb.say(message, channel, network)
  end

end
