class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :church_code,    :null => false
      t.string :mailchimp_key

      t.timestamps
    end
    
    add_index :accounts, :church_code, :unique => true, :name => 'by_church_code'
  end

  def self.down
    drop_table :accounts
  end
end
