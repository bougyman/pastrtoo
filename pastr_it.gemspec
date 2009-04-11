# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{pastr_it}
  s.version = "0.1.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jayson Vaughn", "Michael Fellinger", "Kevin Berry", "TJ Vanderpoel"]
  s.date = %q{2009-04-11}
  s.default_executable = %q{pastr-it}
  s.email = %q{admins@rubyists.com}
  s.executables = ["pastr-it"]
  s.files = ["lib/pastr_it.rb", "bin/pastr-it"]
  s.homepage = %q{http://code.rubyists.com/projects/pastrtoo}
  s.post_install_message = %q{
  See pastr-it -h for usage.  
  A pastr.it account is required for use. 
  You can register for an account by messaging Pastr on Freenode:
    /msg Pastr .register <somepassword>
  }
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A command line program to paste text to http://pastr.it}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httpclient>, [">= 0"])
    else
      s.add_dependency(%q<httpclient>, [">= 0"])
    end
  else
    s.add_dependency(%q<httpclient>, [">= 0"])
  end
end
