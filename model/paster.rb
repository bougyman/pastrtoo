class Paster < Sequel::Model
  one_to_many :paste_entries
end
