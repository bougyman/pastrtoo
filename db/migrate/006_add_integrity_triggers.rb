class AddIntegrityTriggers < Sequel::Migration
  def up
    alter_table :annotations do |t|
      t.add_foreign_key("paste_entry_exists", :paste_entries, :on_delete => :cascade) 
    end unless DB[:annotations].columns.include?(:paste_entry_exists)

    alter_table :paste_entries do |t|
      t.add_foreign_key("paster_exists", :pasters) 
    end
  end

  def down
    alter_table :annotations do |t|
      t.drop_constraint("paste_entry_exists")
    end
    
    alter_table :paste_entries do |t|
      t.drop_constraint("paster_exists")
    end
  end
end
