class Channel < Sequel::Model
  validates_presence_of :filter_id, :network, :name
  many_to_one :filter
end
