class User < Sequel::Model
  one_to_many :pasters, :one_to_one => true
  validates_uniqueness_of :nickname
  def set_pass(pass)
    require "digest/md5"
    require "pastr_it"
    self.password = Digest::MD5.hexdigest([nickname, PastrIt::REALM, pass].join(':'))
  end

end
