class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.belongs_to :client, index: true

      t.timestamps
    end
  end
end
