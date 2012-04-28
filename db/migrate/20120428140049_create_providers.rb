class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :name, null: false
      t.string :imap_address, null: false
      t.integer :imap_port, default: 993
      t.boolean :imap_ssl, default: true

      t.timestamps
    end
  end
end
