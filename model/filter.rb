class Filter < Sequel::Model
  one_to_many :paste_entry
                   
  class << self
    def id_for(channel, network)
      f = filter_for(channel, network)
      f ? f.id : nil
    end
                  
    def filter_for(channel, network)   
      if pastr_channel = ::Channel.find(:name => channel, :network => network)
        pastr_channel.filter
      else         
        Filter.find(:filter_method => "plaintext")
      end
    end
  end

end
