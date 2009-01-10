class AddNetworkToPasteEntries < Sequel::Migration
  def up
    alter_table :paste_entries do
      add_column :network, :varchar 
    end unless DB[:paste_entries].columns.include?(:network)
  end

  def down
    alter_table :paste_entries do
      drop_column :network
    end if DB[:paste_entries].columns.include?(:network)
  end
end
