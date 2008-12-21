gem 'sequel_postgresql_triggers'
require 'sequel_postgresql_triggers'
class MakeTimestampTriggers < Sequel::Migration
  def up
     DB.pgt_created_at(:users, :created_at)
     DB.pgt_created_at(:pasters, :created_at)
     DB.pgt_created_at(:filters, :created_at)
     DB.pgt_created_at(:comments, :created_at)
     DB.pgt_created_at(:annotations, :created_at)
     DB.pgt_created_at(:paste_entries, :created_at)
     DB.pgt_created_at(:bot_users, :created_at)

     DB.pgt_updated_at(:users, :updated_at)
     DB.pgt_updated_at(:pasters, :updated_at)
     DB.pgt_updated_at(:filters, :updated_at)
     DB.pgt_updated_at(:comments, :updated_at)
     DB.pgt_updated_at(:annotations, :updated_at)
     DB.pgt_updated_at(:paste_entries, :updated_at)
     DB.pgt_updated_at(:bot_users, :updated_at)
  end

  def down
  end
end
