class Filter < Sequel::Model
  one_to_many :paste_entry
end
