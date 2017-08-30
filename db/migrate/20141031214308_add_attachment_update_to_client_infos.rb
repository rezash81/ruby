class AddAttachmentUpdateToClientInfos < ActiveRecord::Migration
  def self.up
    change_table :client_infos do |t|
      t.attachment :zipupdate
    end
  end

  def self.down
    remove_attachment :client_infos, :zipupdate
  end
end
