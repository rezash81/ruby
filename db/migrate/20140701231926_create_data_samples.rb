class CreateDataSamples < ActiveRecord::Migration
  def change
    create_table :data_samples do |t|
      t.timestamp :sample_time
      t.integer :ordinal_num
      t.integer :client_ordinal_num

      t.belongs_to :client
      t.timestamps
    end
  end
end
