# Here goes your database connection and options

require "sequel"
require "logger"
PASTR_DB = ENV["PASTR_DB"] unless ENV["PASTR_DB"].nil?
PASTR_DB = "postgres://pastr:pastr_admin@localhost/pastr" unless Object.const_defined? "PASTR_DB"
PASTR_ENV = ENV["PASTR_ENV"] unless ENV["PASTR_ENV"].nil?
PASTR_ENV = "development" unless Object.const_defined? "PASTR_ENV"
DB = Sequel.connect(PASTR_DB, :loggers => Logger.new(File.join(File.dirname(__FILE__),"..","log","#{PASTR_ENV}.log")))
# Require all models in '/model/*.rb'
Dir[File.join(File.dirname(__FILE__), "*.rb")].each { |file| require file }
