class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      # Client attributes
      t.string :static_ip, default: ""
      t.integer :ordinal_num

      # Config
      t.integer :sampling_time, default: 30
      t.integer :samples_count, default: 10
      t.timestamp :last_config

      t.belongs_to :operator
      t.belongs_to :client_info

      t.timestamps
    end
  end
end
