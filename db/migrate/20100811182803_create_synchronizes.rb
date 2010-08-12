class CreateSynchronizes < ActiveRecord::Migration
  def self.up
    create_table :synchronize do |t|
      t.integer :account_id
      t.string :mailchimp_list_id

      t.timestamps
    end
  end

  def self.down
    drop_table :synchronize
  end
end
