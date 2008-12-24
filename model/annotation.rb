class Annotation < Sequel::Model
  many_to_one :paste_entry
  many_to_one :filter
  many_to_one :paster

  validates_presence_of :paster_id, :paste_entry_id

  def text
    self.paste_body
  end

  def syntax
    self.filter ? self.filter.filter_method : "plaintext"
  end

end
