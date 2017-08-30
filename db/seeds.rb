# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ActiveRecord::Base.transaction do
  User.create username: 'admin', password: 'password', user_type: 3

  User.create (1..10).map{|i|
    {username: "user#{i}", name: "user#{i}", password: "password", user_type: 0, email: Faker::Internet.email}
  }

  User.create (1..3).map{|i|
    {username: "operator#{i}", name: "operator#{i}", password: "password", user_type: 1, email: Faker::Internet.email}
  }

  User.create username: "admin", name: "admin", password: "password", user_type: 2, email: Faker::Internet.email

  ClientInfo.create (1..3).map{|i|
    {
      name: "client#{i}",
      guid: SecureRandom.hex(8),
      model_name: "Device #{Faker::Bitcoin.address}",
      serial_number: SecureRandom.hex,
      description: Faker::Lorem.paragraph
    }
  }

  operators = User.operators.all

  Client.create ClientInfo.all.map{|c|
    {
      static_ip: Faker::Internet.ip_v4_address,
      ordinal_num: rand(1000),
      sampling_time: 50,
      samples_count: 5,
      operator_id: operators.sample.id,
      client_info_id: c.id
    }
  }

  Sensor.create [
    {channel_index: 0, name: "Evap - Last"},
    {channel_index: 1, name: "Evap - Min"},
    {channel_index: 2, name: "Evap - Max"},
    {channel_index: 3, name: "Evap - Avg"},
    {channel_index: 4, name: "Pressure - Last"},
    {channel_index: 5, name: "Pressure - Min"},
    {channel_index: 6, name: "Pressure - Max"},
    {channel_index: 7, name: "Pressure - Avg"},
    {channel_index: 8, name: "Wind Speed - Last"},
    {channel_index: 9, name: "Wind Speed - Min"},
    {channel_index: 10, name: "Wind Speed - Max"},
    {channel_index: 11, name: "Wind Speed - Avg"},
    {channel_index: 12, name: "Humidity - Last"},
    {channel_index: 13, name: "Humidity - Min "},
    {channel_index: 14, name: "Humidity - Max"},
    {channel_index: 15, name: "Humidity - Avg"},
    {channel_index: 16, name: "Tepmrature - Last"},
    {channel_index: 17, name: "Tepmrature - Min"},
    {channel_index: 18, name: "Tepmrature - Max"},
    {channel_index: 19, name: "Tepmrature - Avg"},
    {channel_index: 20, name: "Wind Direction-Last"},
    {channel_index: 21, name: "Wind Direction-Min"},
    {channel_index: 22, name: "Wind Direction-Max"},
    {channel_index: 23, name: "Wind Direction-Avg"},
    {channel_index: 24, name: "Rain - Last"},
    {channel_index: 25, name: "Rain - Min"},
    {channel_index: 26, name: "Rain - Max"},
    {channel_index: 27, name: "Rain - Avg"}
  ]

  sensors = Sensor.all

  ClientSensor.create Client.all.map{|c|
    sensors.sample(rand(8)+8).map{|s| {client_id: c.id, sensor_id: s.id} }
  }.flatten

  date1 = 2.months.ago
  date2 = Time.now
  counter = 0
  DataSample.create Client.all.map{|c|
    (0..100).map{
      counter += 1
      {
        sample_time: Time.at((date2.to_f - date1.to_f)*rand + date1.to_f),
        ordinal_num: counter,
        client_ordinal_num: c.ordinal_num,
        client_id: c.id
      }
    }
  }.flatten

  SampleValue.create Client.all.map{|c|
    ss = c.sensors.all
    value = (20*rand).round(2)
    c.samples.map{|d|
      ss.map{|s|
        value = (value + (20*rand) - 10).abs.round(2)
        {
          sample_ordinal_num: d.ordinal_num,
          channel_index: s.channel_index,
          sensor_id: s.id,
          client_id: d.client_id,
          sample_time: d.sample_time,
          value: value
        }
      }
    }.flatten
  }.flatten
end