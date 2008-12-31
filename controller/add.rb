class Add < Controller
  def index(*nums)
    nums.inject(0) { |l,t| l += t.to_i }
  end
end
