class Annotation < Sequel::Model
  many_to_one :paste_entry
  many_to_one :filter
  before_save :update_now

  def update_now
    self.updated_at = Time.now
  end
end
