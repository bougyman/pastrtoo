class Annotation < Sequel::Model
  many_to_one :paste_entry
  many_to_one :filter

end
