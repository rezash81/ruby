class ClientSensor < ActiveRecord::Base
  belongs_to :client
  belongs_to :sensor
end
