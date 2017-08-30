class DataSample < ActiveRecord::Base
  belongs_to :client

  default_scope {order('sample_time DESC')}
end
