class CreateAnnotations < Sequel::Migration
  def up
    create_table :annotations do
      primary_key :id
      text :paste_body
      integer :paste_entry_id
      integer :paster_id
      boolean :private
      integer :filter_id
      timestamp :created_at, :default => "now()"
      timestamp :updated_at, :default => "now()"
      varchar  :channel
      varchar :paste_key
      varchar :title
      integer :version
      varchar :reply_to
    end unless DB.table_exists?(:annotations)
  end

  def down
    drop_table :annotations if DB.table_exists?(:annotaions)
  end
end
