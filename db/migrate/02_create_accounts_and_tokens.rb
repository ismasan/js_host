class CreateAccountsAndTokens < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :email
      t.string :password
    end

    create_table :tokens do |t|
      t.references :account
      t.string :key
      t.string :secret
    end

    add_column :projects, :account_id, :integer

    add_index :projects, :account_id
    add_index :tokens, :account_id
  end

  def self.down
    remove_column :projects, :account_id
    drop_table :accounts
    drop_table :tokens
  end
end
