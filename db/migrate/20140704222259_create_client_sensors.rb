class CreateClientSensors < ActiveRecord::Migration
  def change
    create_table :client_sensors do |t|
      t.belongs_to :client, index: true
      t.belongs_to :sensor, index: true

      t.timestamps
    end
  end
end
