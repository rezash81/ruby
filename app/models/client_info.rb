class ClientInfo < ActiveRecord::Base
  has_many :data_samples
  has_many :sample_values
  has_many :sensors
  has_many :clients

  has_attached_file :zipupdate
  validates_attachment_content_type :zipupdate, :content_type => /\Aapplication\/.*\Z/

  validates_presence_of :guid, message: "#{I18n.t 'guid'} نمیتواند خالی باشد"
end
