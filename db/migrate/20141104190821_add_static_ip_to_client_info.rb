class AddStaticIpToClientInfo < ActiveRecord::Migration
  def change
  	change_table :client_infos do |t|
  		t.string :static_ip, default: ""
  	end
  end
end
