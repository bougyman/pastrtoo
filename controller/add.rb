class Add < Controller
  def index(*nums)
    nums.inject(0) { |l,t| l += t.to_i }
  end

  def reqtest
    response.set_cookie("pastr_nickname", :path => '/', :value => "bougyman", :expires => Time.now + (24 * 3600 * 365))
    Ramaze::Log.info("set cookie to bougyman")
    redirect Rs(:cooktest)
  end

  def cooktest
    h request.cookies.inspect + " - #{request.cookies["pastr_nickname"]}"
  end
end
