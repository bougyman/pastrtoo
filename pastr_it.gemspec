PASTR_IT_SPEC = Gem::Specification.new do |spec|
  spec.name = "pastr_it"
  spec.version = "0.1.0"
  spec.add_dependency "httpclient"
  spec.summary = 'A command line program to paste text to http://pastr.it'
  spec.authors = ["Jayson Vaughn", "Michael Fellinger", "Kevin Berry", "TJ Vanderpoel"]
  spec.email = "admins@rubyists.com"
  spec.homepage = "http://code.rubyists.com/projects/pastrtoo"

  spec.files = ["lib/pastr_it.rb", "bin/pastr-it"]
  spec.executables = ["pastr-it"]
  spec.require_path = "lib"
  spec.post_install_message = "See pastr-it -h for usage.  
  A pastr.it account is required for use. 
  New Accounts must be given by a pastr admin (bougyman, thedonvaughn, death_syn on freenode)"

end

