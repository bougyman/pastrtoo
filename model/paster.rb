class Paster < Sequel::Model
  one_to_many :paste_entries
  many_to_one :user
  validates_presence_of :nickname
  validates_uniqueness_of :nickname
end
