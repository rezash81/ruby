class SampleValue < ActiveRecord::Base
  belongs_to :client
  belongs_to :sensor

  default_scope {order('sample_time DESC')}
end
