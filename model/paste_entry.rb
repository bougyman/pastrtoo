class PasteEntry < Sequel::Model
  many_to_one :paster
  many_to_one :filter

  def text
    self.paste_body
  end

  def syntax
    self.filter ? self.filter.filter_method : "plaintext"
  end

end
