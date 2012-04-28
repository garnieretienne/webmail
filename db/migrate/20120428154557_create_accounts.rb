class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :email_address, null: false
      t.references :provider, null: false

      t.timestamps
    end

    # Create an index on the email column (email are unique)
    add_index(:accounts, :email_address, unique: true)

    # Add a foreign key in the database in SQL
    # see: https://gist.github.com/1605432
    # 'ADD CONSTRAINT' is not supported in SQLITE3
    # see: http://www.sqlite.org/omitted.html
    if Webmail::Application.config.database_configuration[Rails.env]["adapter"] != "sqlite3"
      execute "ALTER TABLE accounts ADD CONSTRAINT fk_provider FOREIGN KEY (provider_id) REFERENCES providers (id);"
    end
  end
end
