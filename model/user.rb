class User < Sequel::Model
  one_to_many :pasters, :one_to_one => true
end
