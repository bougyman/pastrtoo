class AddPasswordToUsers < Sequel::Migration
  def up
    alter_table :users do |t|
      t.add_column("password", :text) 
    end
  end

  def down
    alter_table :users do |t|
      t.drop_column("password") 
    end
  end
end
