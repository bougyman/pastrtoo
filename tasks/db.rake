namespace :db do
  desc "migrate"
  task :migrate_to_current do
    puts "Migrating database"
    sequel = IO.popen("sequel postgres://pastr:pastr_admin@localhost/pastr -m db/migrate")
    while s = sequel.gets
      puts s.chomp
    end
  end
end
