class AddMeasureUnitToSensors < ActiveRecord::Migration
  def change
  	change_table :sensors do |t|
  		t.string :measure_unit , default: ""
  	end
  end
end
