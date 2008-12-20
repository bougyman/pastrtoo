class PasteEntry < Sequel::Model
  many_to_one :paster
  many_to_one :filter
  before_create :set_defaults
  before_save :update_now

  def set_defaults
    self.created_at = Time.now
    update_now
  end

  def update_now
    self.updated_at = Time.now
  end
end
