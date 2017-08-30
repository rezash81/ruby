class CreateClientInfos < ActiveRecord::Migration
  def change
    create_table :client_infos do |t|
      t.string :name, null: false
      t.string :position
      t.string :guid

      # Hardware attributes
      t.string :model_name, default: ""
      t.string :serial_number, default: ""
      t.timestamp :product_date_time
      t.binary :hw_config, default: ""
      t.integer :client_status, null: false, default: 0

      t.string :description

      t.timestamps
    end
  end
end
