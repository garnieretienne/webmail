class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :uid, null: false
      t.string :subject
      t.string :from_name
      t.string :from_address, null: false
      t.datetime :internal_date, null: false
      t.string :flag_attr
      t.references :mailbox, null: false
    end
    add_index :messages, :mailbox_id

    # Create indexes for faster search
    add_index :messages, :uid
    add_index :messages, :subject
    add_index :messages, :from_address

    # Add a foreign key in the database in SQL
    # see: https://gist.github.com/1605432
    # 'ADD CONSTRAINT' is not supported in SQLITE3
    # see: http://www.sqlite.org/omitted.html
    if Webmail::Application.config.database_configuration[Rails.env]["adapter"] != "sqlite3"
      execute "ALTER TABLE messages ADD CONSTRAINT fk_mailbox FOREIGN KEY (mailbox_id) REFERENCES mailboxes (id);"
    end
  end
end
