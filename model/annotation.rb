require File.join(File.dirname(__FILE__), "paste_section") unless Object.const_defined?("PasteSection")
class Annotation < Sequel::Model
  include PasteSection::SectionHelper
  many_to_one :paste_entry
  many_to_one :filter
  many_to_one :paster
  before_create :filter_it
  before_save :filter_it

  after_create :notify_channel
  validates_presence_of :paster_id, :paste_entry_id

  def text
    self.paste_body
  end

  def syntax
    self.filter_id ? (self.filter.nil? ? self.reload.filter.filter_method : filter.filter_method ) : "plaintext"
  end

  def network
    paste_entry.network
  end

  def channel
    paste_entry.channel
  end

  def number_of_lines
    "#{(n_lines = text.split(/\n/).size)} line#{n_lines == 1 ? "" : "s"}"
  end

  def view_link
    "%s/%s-%s" % ["http://pastr.it", paste_entry.id, (paste_entry.annotations.sort { |a,b| a.id <=> b.id }.index(self) + 1)]
  end

  private
  def filter_it
    if filter_id.nil?
      Ramaze::Log.info("filter_id is #{filter_id}, #{channel}, #{network}")
      filter_id = self.filter_id = self[:filter_id] = Filter.id_for(channel, network)
      Ramaze::Log.info("filter_id is #{filter_id}, #{channel}, #{network}")
    end
  end

  def notify_channel
    require File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "pastr_drb")) unless Object.const_defined?("PastrDrb")
    message = "#{paster.nickname} annotated #{view_link} (#{title || 'Untitled'}), with #{number_of_lines} of #{syntax}"
    PastrDrb.say(message, channel, network, paster.nickname)
  end
end
