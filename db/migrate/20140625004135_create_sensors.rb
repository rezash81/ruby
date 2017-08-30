class CreateSensors < ActiveRecord::Migration
  def change
    create_table :sensors do |t|
      t.string :name
      t.text :description

      # t.integer :client_ordinal_num
      t.integer :channel_index
      t.integer :code
      t.integer :unit_code
      t.string :unit_avb
      t.integer :saving_type
      t.integer :channel_type
      t.integer :hw_port_type
      t.integer :hw_port_number
      t.integer :hw_port_pin_number
      t.integer :calculation_type
      t.boolean :is_active
      t.binary :calibration_table_bin

      t.integer :channel_index

      t.timestamps
    end
  end
end
