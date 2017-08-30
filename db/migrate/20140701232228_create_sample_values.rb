class CreateSampleValues < ActiveRecord::Migration
  def change
    create_table :sample_values do |t|
      t.integer :sample_ordinal_num
      t.integer :channel_index
      t.timestamp :sample_time
      t.belongs_to :client
      t.belongs_to :sensor

      t.float :value

      t.timestamps
    end
  end
end
