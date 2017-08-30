class Sensor < ActiveRecord::Base
  has_many :client_sensors
  has_many :sensors, through: :client_sensors

  validates_presence_of :name, message: "#{I18n.t 'name'} نمیتواند خالی باشد"
  validates_presence_of :channel_index, message: "#{I18n.t 'channel_index'} نمیتواند خالی باشد"
end
