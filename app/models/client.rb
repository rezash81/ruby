class Client < ActiveRecord::Base
  belongs_to :operator, class_name: "User"
  belongs_to :position
  belongs_to :client_info
  has_many :client_sensors
  has_many :sensors, through: :client_sensors
  has_many :values, foreign_key: 'client_id', class_name: "SampleValue"
  has_many :samples, foreign_key: 'client_id', class_name: "DataSample"

  has_many :attachments

  validates_presence_of :client_info, message: "#{I18n.t 'client_info'} نمیتواند خالی باشد"

  def get_default_attachment
    default_attachment && attachments.where(id: default_attachment).first
  end

  def name
    client_info ? client_info.name : I18n.t('client')
  end

  def create_export_query(start_time, end_time, sensors)
    "SELECT \"sample_values\".\"value\", \"sample_values\".\"sample_time\", \"sample_values\".\"sample_ordinal_num\", \"sample_values\".\"channel_index\" FROM \"sample_values\" WHERE \"sample_values\".\"client_id\" = #{id} AND \"sample_values\".\"channel_index\" IN (#{sensors.collect(&:channel_index).join(', ')}) AND (\"sample_values\".\"sample_time\" BETWEEN '#{start_time.year}-#{start_time.month}-#{start_time.day} #{start_time.hour}:#{start_time.min}:#{start_time.sec}' AND '#{end_time.year}-#{end_time.month}-#{end_time.day} #{end_time.hour}:#{end_time.min}:#{end_time.sec}') ORDER BY sample_time DESC"
  end

  def create_export_live_query(start_time, end_time, sensor)
    "SELECT \"sample_values\".\"value\", \"sample_values\".\"sample_time\", \"sample_values\".\"sample_ordinal_num\", \"sample_values\".\"channel_index\" FROM \"sample_values\" WHERE \"sample_values\".\"client_id\" = #{id} AND \"sample_values\".\"channel_index\" = #{sensor.channel_index} AND (\"sample_values\".\"sample_time\" BETWEEN '#{start_time.year}-#{start_time.month}-#{start_time.day} #{start_time.hour}:#{start_time.min}:#{start_time.sec}' AND '#{end_time.year}-#{end_time.month}-#{end_time.day} #{end_time.hour}:#{end_time.min}:#{end_time.sec}') ORDER BY sample_time DESC"
  end

  def create_show_query(start_time, end_time, sensors)
    end_time = end_time.utc
    start_time = start_time.utc
    "SELECT \"sample_values\".\"value\", \"sample_values\".\"channel_index\", \"sample_values\".\"sample_time\" FROM \"sample_values\" WHERE \"sample_values\".\"client_id\" = #{id} AND \"sample_values\".\"channel_index\" IN (#{sensors.collect(&:channel_index).join(', ')}) AND (\"sample_values\".\"sample_time\" BETWEEN '#{start_time.year}-#{start_time.month}-#{start_time.day} #{start_time.hour}:#{start_time.min}:#{start_time.sec}' AND '#{end_time.year}-#{end_time.month}-#{end_time.day} #{end_time.hour}:#{end_time.min}:#{end_time.sec}') ORDER BY sample_time DESC"
  end

  def show(start_time, end_time, sensors, range_selector, average)
    _config = Rails.configuration.database_configuration[Rails.env]
    db_conf = "dbname=#{_config["database"]} user=#{_config["username"]} password=#{_config["password"]}"
    sql = create_show_query start_time, end_time, sensors
    # puts "\"#{db_conf}\" \"#{sql}\" \"#{sensors.collect(&:channel_index).join(' ')}\""
    result = `bin/show_data "#{db_conf}" "#{sql}" "#{sensors.collect(&:channel_index).join(' ')}" "#{range_selector}" "#{average}"`
    # puts ">> #{result}"
    return result
  end

  def create_compare_query(start_time, end_time, id1, s1, id2, s2)
    end_time = end_time.utc
    start_time = start_time.utc
    "SELECT sample_values.value, concat(sample_values.client_id, sample_values.channel_index), sample_values.sample_time FROM sample_values WHERE ( (sample_values.client_id = #{id1} AND sample_values.channel_index = #{s1}) OR (sample_values.client_id = #{id2} AND sample_values.channel_index = #{s2}) ) AND (sample_values.sample_time BETWEEN '#{start_time.year}-#{start_time.month}-#{start_time.day} #{start_time.hour}:#{start_time.min}:#{start_time.sec}' AND '#{end_time.year}-#{end_time.month}-#{end_time.day} #{end_time.hour}:#{end_time.min}:#{end_time.sec}') ORDER BY sample_time DESC "
  end

  def compare(start_time, end_time, range_selector, average, id1, s1, id2, s2)
    _config = Rails.configuration.database_configuration[Rails.env]
    db_conf = "dbname=#{_config["database"]} user=#{_config["username"]} password=#{_config["password"]}"
    sql = create_compare_query start_time, end_time, id1, s1, id2, s2
    # puts "\"#{db_conf}\" \"#{sql}\" \"#{sensors.collect(&:channel_index).join(' ')}\""
    result = `bin/show_data "#{db_conf}" "#{sql}" "#{id1}#{s1} #{id2}#{s2}" "#{range_selector}" "#{average}"`
    # puts ">> #{result}"
    return result
  end

  def export_shown_data(start_time, end_time, sensors, range_selector, average)
    _config = Rails.configuration.database_configuration[Rails.env]
    db_conf = "dbname=#{_config["database"]} user=#{_config["username"]} password=#{_config["password"]}"
    sql = create_show_query start_time, end_time, sensors
    # puts "\"#{db_conf}\" \"#{sql}\" \"#{sensors.collect(&:channel_index).join(' ')}\""
    result = `bin/export_shown_data "#{db_conf}" "#{sql}" "#{sensors.collect(&:channel_index).join(' ')}" "#{range_selector}" "#{average}"`
    # puts ">> #{result}"
    rows = result.split("\n").collect{|row| row.split('#')}
    csv = (['Date'] + sensors.collect{|s| s.name + '(' + s.measure_unit + ')'}).join(",")+"\n"
    csv += ([''] + sensors.collect(&:channel_index)).join(",")+"\n"
    rows.each do |row|
      time = DateTime.parse(row[0]).in_time_zone("Tehran")
      csv += "#{JalaliDate.new(time).format("%Y/%m/%d")} - #{time.strftime("%H:%M:%S")},#{row[1]}\n"
    end
    return csv
  end

  def export_live_data(start_time, end_time, sensor)
    end_time = end_time.utc
    start_time = start_time.utc
    _config = Rails.configuration.database_configuration[Rails.env]
    db_conf = "dbname=#{_config["database"]} user=#{_config["username"]} password=#{_config["password"]}"
    sql = create_export_live_query start_time, end_time, sensor
    # puts "\"#{db_conf}\" \"#{sql}\" \"#{sensors.collect(&:channel_index).join(' ')}\""
    result = `bin/export_standard "#{db_conf}" "#{sql}" "#{sensor.channel_index}"`
    # puts ">> #{result}"
    rows = result.split("\n").collect{|row| row.split('#')}
    # puts ">> #{rows}"
    
    csv = (['Date', 'Row', sensor.name + '(' + sensor.measure_unit + ')']).join(",")+"\n"
    csv += (['', 'ordinal_num', sensor.channel_index]).join(",")+"\n"
    rows.each do |row|
      time = DateTime.parse(row[0]).in_time_zone("Tehran")
      csv += "#{JalaliDate.new(time).format("%Y/%m/%d")} - #{time.strftime("%H:%M:%S")},#{row[1]},#{row[2]}\n"
    end

    return csv
  end

  def export(start_time, end_time, sensors, standard = false)
    end_time = end_time.utc
    start_time = start_time.utc
    _config = Rails.configuration.database_configuration[Rails.env]
    db_conf = "dbname=#{_config["database"]} user=#{_config["username"]} password=#{_config["password"]}"
    sql = create_export_query start_time, end_time, sensors
    # puts "\"#{db_conf}\" \"#{sql}\" \"#{sensors.collect(&:channel_index).join(' ')}\""
    result = `bin/export_standard "#{db_conf}" "#{sql}" "#{sensors.collect(&:channel_index).join(' ')}"`
    # puts ">> #{result}"
    rows = result.split("\n").collect{|row| row.split('#')}
    # puts ">> #{rows}"
    if standard
      csv = (['Year', 'Month', 'Day', 'Hour', 'Minute', 'Second'] + sensors.collect{|s| s.name + '(' + s.measure_unit + ')'}).join(",")+"\n"
      rows.each do |row|
        time = DateTime.parse(row[0]).in_time_zone("Tehran")
        jt = JalaliDate.new time
        csv += "#{jt.year},#{jt.month},#{jt.day},#{time.hour},#{time.min},#{time.sec},#{row[2]}\n"
      end
    else
      csv = (['Date', 'Row'] + sensors.collect{|s| s.name + '(' + s.measure_unit + ')'}).join(",")+"\n"
      csv += (['', 'ordinal_num'] + sensors.collect(&:channel_index)).join(",")+"\n"
      rows.each do |row|
        time = DateTime.parse(row[0]).in_time_zone("Tehran")
        csv += "#{JalaliDate.new(time).format("%Y/%m/%d")} - #{time.strftime("%H:%M:%S")},#{row[1]},#{row[2]}\n"
      end
    end
    csv
  end

  def query_range(start_time, end_time)
    # ActiveRecord::Base.connection.execute("SELECT id,sample_ordinal_num,sample_time,value,channel_index FROM sample_values WHERE client_id = #{id} AND (sample_time BETWEEN #{} AND #{}) ORDER BY sample_time DESC")
    # values.where(sample_time: start_time..end_time).pluck(:id, :sample_ordinal_num, :sample_time, :value, :channel_index)
    ActiveRecord::Base.connection.execute(create_export_query start_time, end_time).entries
  end

  def group_query_by_ordinal(start_time, end_time)
    query_range(start_time, end_time).group_by{|v| v["sample_ordinal_num"]}
  end

end
