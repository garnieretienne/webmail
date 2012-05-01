class CreateMailboxes < ActiveRecord::Migration
  def change
    create_table :mailboxes do |t|
      t.string :name, null: false
      t.string :delimiter, null: false
      t.string :flag_attr
      t.references :account, null: false
    end
    add_index :mailboxes, :account_id

    # Create an index on the mailbox name
    add_index :mailboxes, :name

    # Add a foreign key in the database in SQL
    # see: https://gist.github.com/1605432
    # 'ADD CONSTRAINT' is not supported in SQLITE3
    # see: http://www.sqlite.org/omitted.html
    if Webmail::Application.config.database_configuration[Rails.env]["adapter"] != "sqlite3"
      execute "ALTER TABLE mailboxes ADD CONSTRAINT fk_account FOREIGN KEY (account_id) REFERENCES accounts (id);"
    end
  end
end
