gem 'sequel_postgresql_triggers'
require 'sequel_postgresql_triggers'
class CreateChannels < Sequel::Migration
  def up
    create_table :channels do
      primary_key :id
      varchar :name 
      varchar :filter_id # Link to preferred language filter for channel
      varchar :network
      text :description 
      timestamp :created_at
      timestamp :updated_at
    end unless DB.table_exists?(:channels)
    DB.pgt_updated_at(:channels, :updated_at)
    DB.pgt_created_at(:channels, :created_at)
  end

  def down
    drop_table :channels if DB.table_exists?(:channels)
  end
end
