class AddDefaultAttachmentToClient < ActiveRecord::Migration
  def change
    change_table :clients do |t|
      t.integer :default_attachment
    end
  end
end
