class ClientsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_client, only: [:show, :edit, :update, :destroy, :archive_data]
  before_action {@app = true}
  before_action {@tab = 'client'}

  # GET /clients
  # GET /clients.json
  def index
    @clients = Client.all
  end

  def check_new
    @sensor = @client.sensors.where(channel_index: params[:channel]).first if params[:channel]
    values = []
    if not params[:last].blank? and @sensor
      last = Time.at(params[:last].to_i+1)
      values = @client.values.where(channel_index: @sensor.channel_index).where('sample_time > ?', last)
    end
    # if values.count > 0
    #   values.each do |t|
    #     puts ">> #{t.sample_time-t.sample_time.utc_offset}"
    #   end
    # end
    if values.count > 0
      last = values.collect(&:sample_time).max.to_i
      values = values.sort_by(&:sample_time).reverse
      render json: {last: values.first.sample_time.to_i, values: values.map{|v| [v.sample_time.to_i, v.value.round_n] }}
    else
      render json: {values: []}
    end
  end

  # GET /clients/1
  # GET /clients/1.json
  def show
    @first_value = @client.values.where(channel_index: @client.sensors.pluck(:channel_index)).first
  end

  def archive_data
    if params.has_key?(:range)
      @range = params[:range].to_i
    else
      @range = 3
    end
    range_selector = @range == 0 ? @client.sampling_time : UConf[:range_selector][@range]
    range_selector = @client.sampling_time if not range_selector or range_selector < @client.sampling_time
    range_selector = range_selector.to_i
    @average = params[:average].to_i
    @sensors = @client.sensors.where(channel_index: params[:channel]).sort_by(&:channel_index).to_a
    gsensors = @sensors.group_by(&:channel_index)

    @first_value = @client.values.where(channel_index: @client.sensors.pluck(:channel_index)).first
    
    begin
      @from = JalaliDate.new( *(params[:from].split('/').collect(&:to_i))) if params[:from]
      @to = JalaliDate.new( *(params[:to].split('/').collect(&:to_i))) if params[:to]
    rescue ArgumentError
    end


    return if not @from or not @to
    # return flash.now[:error] = "ابتدای بازه انتخاب نشده است." unless @from
    # return flash.now[:error] = "انتهای بازه انتخاب نشده است." unless @to

    
    from_g = @from.to_g.to_datetime.in_time_zone("Tehran").at_beginning_of_day
    to_g = @to.to_g.to_datetime.in_time_zone("Tehran").at_end_of_day
    # my_logger.info "#{from_g}     #{to_g}"
    first_value = @client.values.where(channel_index: gsensors.keys, sample_time: from_g..to_g).first
    last_value = @client.values.where(channel_index: gsensors.keys, sample_time: from_g..to_g).last
    
    return flash.now[:error] = "بازه انتخاب شده اشتباه می باشد." unless from_g <= to_g
    return flash.now[:error] = "هیچ داده‌ای در این بازه وجود ندارد" unless first_value
    
    if to_g > first_value.sample_time
      to_g = first_value.sample_time
      @to = JalaliDate.new to_g
    end
    if from_g < last_value.sample_time
      from_g = last_value.sample_time
      @from = JalaliDate.new from_g
    end

    limit = 5000
    if (to_g.to_i - from_g.to_i) / range_selector > limit
      from_g = to_g - (limit*range_selector).seconds
      @from = JalaliDate.new from_g
      flash.now[:error] = "داده‌های دوره‌ی درخواست شده غیر قابل پردازش است." 
    end

    if params[:channel] and params[:channel].is_a? Array
      @chartLabels = ['تاریخ']
      @sensors.each{|s| @chartLabels << s.name+" ("+s.measure_unit+")"}
      # Rails.logger.info ">>>#{@chartLabels}"
      @from_g = from_g
      @to_g = to_g
      @range_selector = range_selector
      @chartData = @client.show(from_g, to_g, @sensors, range_selector, @average)
      # Rails.logger.info ">>>>#{@chartData}"
      if @client.values.first
        @last_value = @client.values.first.sample_time.to_i
      else
        @last_value = 0
      end
    end
  rescue ArgumentError
  #   return redirect_to client_path(@client)
  end

  def compare
    if params.has_key?(:range)
      @range = params[:range].to_i
    else
      @range = 3
    end
    @tab = 'compare'
    @clients = Client.includes(:sensors).all.to_a
    @average = params[:average].to_i
    @sensor1 = nil
    @sensor2 = nil
    
    if params[:channel2] and params[:channel1]
      channel1 = params[:channel1].split(",")
      @client1 = @clients.find{|c| c.id == channel1[0].to_i}
      return unless @client1
      @sensor1 = @client1.sensors.where(channel_index: channel1[1]).first
      return unless @sensor1
      channel2 = params[:channel2].split(",")
      @client2 = @clients.find{|c| c.id == channel2[0].to_i}
      return unless @client2
      @sensor2 = @client2.sensors.where(channel_index: channel2[1]).first
      return unless @sensor2
    end
    
    begin
      @from = JalaliDate.new( *(params[:from].split('/').collect(&:to_i))) if params[:from]
      @to = JalaliDate.new( *(params[:to].split('/').collect(&:to_i))) if params[:to]
    rescue ArgumentError
    end
    
    if @sensor1 and @sensor2 and @from and @to
      @range = params[:range].to_i
      min_range = [@client1.sampling_time, @client2.sampling_time].min
      range_selector = @range == 0 ? min_range : UConf[:range_selector][@range]
      range_selector = min_range if not range_selector or range_selector < min_range
      from_g = @from.to_g.to_datetime.in_time_zone("Tehran").at_beginning_of_day
      to_g = @to.to_g.to_datetime.in_time_zone("Tehran").at_end_of_day
      first_value1 = @client1.values.where(channel_index: @sensor1.channel_index, sample_time: from_g..to_g).first
      last_value1 = @client1.values.where(channel_index: @sensor1.channel_index, sample_time: from_g..to_g).last
      first_value2 = @client2.values.where(channel_index: @sensor2.channel_index, sample_time: from_g..to_g).first
      last_value2 = @client2.values.where(channel_index: @sensor2.channel_index, sample_time: from_g..to_g).last

      return flash.now[:error] = "بازه انتخاب شده اشتباه می باشد." unless from_g <= to_g
      return flash.now[:error] = "هیچ داده‌ای در این بازه وجود ندارد." if first_value1.nil? and first_value2.nil?
      
      if first_value1.nil?
        first_value = first_value2.sample_time
        last_value = last_value2.sample_time
      elsif first_value2.nil?
        first_value = first_value1.sample_time
        last_value = last_value1.sample_time
      else
        first_value = [first_value1.sample_time, first_value2.sample_time].max
        last_value = [last_value1.sample_time, last_value2.sample_time].min
      end

      if to_g > first_value
        to_g = first_value
        @to = JalaliDate.new to_g
      end
      if from_g < last_value
        from_g = last_value
        @from = JalaliDate.new from_g
      end
      limit = 5000
      if (to_g.to_i - from_g.to_i) / range_selector > limit
        from_g = to_g - (limit*range_selector).seconds
        @from = JalaliDate.new from_g
        flash.now[:error] = "داده‌های دوره‌ی درخواست شده غیر قابل پردازش است." 
      end

      @chartLabels = ['تاریخ', "#{@client1.name} - #{@sensor1.name}(#{@sensor1.measure_unit})", "#{@client2.name} - #{@sensor2.name}(#{@sensor2.measure_unit})"]
      @chartData = @client1.compare(from_g, to_g, range_selector, @average, @client1.id, @sensor1.channel_index, @client2.id, @sensor2.channel_index)

    end
  rescue ArgumentErrore
    # return redirect_to client_path(@client)
  end

  def live
    @sensor = @client.sensors.where(channel_index: params[:channel]).first if params[:channel]
    if @sensor
      values = @client.values.where(channel_index: @sensor.channel_index).limit(100).reverse
      @first_value = values.last
      
      @from = values.first.sample_time.to_datetime.in_time_zone("Tehran")
      
      @chartData = "["
      values.each do |v|
        # t = v.sample_time
        # @chartData += "[new Date(#{t.year},#{t.month-1},#{t.day},#{t.hour},#{t.min},#{t.sec}),#{v.value}],"
        @chartData += "[new Date(\"#{v.sample_time.to_datetime.strftime}\"),#{v.value.round_n}],"
      end
      @chartData = @chartData[0..-2]+"]"
      if @first_value
        @last_value = @first_value.sample_time.to_i
      else
        @last_value = 0
      end
      @chartLabels = ['تاریخ', @sensor.name+"("+@sensor.measure_unit+")"]
    end
  end

  def get_sensors
    @sensors = @client.sensors
  end

  def update_sensors
    if params[:sensors] and params[:sensors].is_a? Array
      @client.update_attributes sensor_ids: params[:sensors]
    end
    @sensors = @client.sensors
    render 'get_sensors'
  end

  def attachments
    @attachments = @client.attachments
  end

  def add_attachment
    if params[:files]
      puts ">> #{params[:files]}"
      if params[:files].is_a? Array
        params[:files].each do |file|
          @client.attachments.create file: file
        end
      else
        @client.attachments.create file: params[:files]
      end
    end
    redirect_to attachments_client_path(@client)
  end

  def set_default_attachment
    @client.update_attributes default_attachment: params[:aid]
    redirect_to attachments_client_path(@client)
  end

  def delete_attachment
    @client.attachments.find(params[:aid]).destroy
    redirect_to attachments_client_path(@client)
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients
  # POST /clients.json
  def create
    @client = Client.new(client_params)
    if @client.save
      if params[:zipupdate] or params[:static_ip]
        _params = {}
        _params[:static_ip] = params[:static_ip] if params[:static_ip]
        _params[:zipupdate] = params[:zipupdate] if params[:zipupdate]
        @client.client_info.update _params
      end
      redirect_to @client
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /clients/1
  # PATCH/PUT /clients/1.json
  def update
    if params[:zipupdate] or params[:static_ip]
      _params = {}
      _params[:static_ip] = params[:static_ip] if params[:static_ip]
      _params[:zipupdate] = params[:zipupdate] if params[:zipupdate]
      @client.client_info.update _params
    end
    if @client.update(client_params true)
      redirect_to clients_url
    else
      render action: 'edit'
    end
  end

  # DELETE /clients/1
  # DELETE /clients/1.json
  def destroy
    @client.destroy
    redirect_to clients_url
  end

  def import_usb
    set_client
  end

  def conv_int(arr)
    arr.reverse.reduce{|memo, i| memo << 8 | i}
  end

  def import_usb_post
    set_client

    unless params[:file]
      return render 'import_usb'
    end

    sensors = Sensor.all.to_a.group_by(&:channel_index)

    string = `bin/usb_parser #{params[:file].path}`
    barr = string.split("\n").map{|s| s.split(",")}
        
    ActiveRecord::Base.transaction do
      sample_create = []
      value_create = []
      sample_ords = []
      barr.each do |row|
        ordinal_num , year, month , day , day_of_week , hour, minute, second = row
        date = Time.new year, month, day, hour, minute, second
        ordinal_num = ordinal_num.to_i
        sample_create << "#{@client.id},#{ordinal_num},#{@client.ordinal_num},#{date.strftime("%Y-%m-%d %H:%M:%S")}\n"
        sample_ords << ordinal_num
        28.times do |idx|
          channel_index = row[8+(idx*2)].to_i
          value = row[8+(idx*2+1)].to_f
          if sensors[channel_index]
            sensor = sensors[channel_index][0]
            value_create << "#{@client.id},#{ordinal_num},#{channel_index},#{value},'#{date.strftime("%Y-%m-%d %H:%M:%S")}',#{sensor.id}\n"
          end
        end
      end
      @client.samples.where(ordinal_num: sample_ords).delete_all
      @client.values.where(sample_ordinal_num: sample_ords).delete_all
      conn = ActiveRecord::Base.connection
      rc = conn.raw_connection
      rc.exec "COPY sample_values (client_id,sample_ordinal_num,channel_index,value,sample_time,sensor_id) FROM STDIN WITH CSV"
      value_create.each{|row| rc.put_copy_data row}
      rc.put_copy_end
      while res = rc.get_result
        if e_message = res.error_message
          Rails.logger.debug ">>PG: #{e_message[0..50]+(e_message.length > 50 ? '...' : '')}"
        end
      end
      rc.exec "COPY data_samples (client_id,ordinal_num,client_ordinal_num,sample_time) FROM STDIN WITH CSV"
      sample_create.each{|row| rc.put_copy_data row}
      rc.put_copy_end
      while res = rc.get_result
        if e_message = res.error_message
          Rails.logger.debug ">>PG: #{e_message[0..50]+(e_message.length > 50 ? '...' : '')}"
        end
      end
    end
    flash.now[:notice] = "اطلاعات با موفقیت ثبت شد"
    return render 'import_usb'
  end

  def import
    set_client
  end

  def import_data
    set_client
    if params[:file]
      csv = CSV.read(params[:file].path)
      @sensor_indeces = []
      @imported_data = {}
      @dates = {}
      csv.each do |line|
        ordinal_num = line[1].to_i
        if line[1] == 'ordinal_num'
          @sensor_indeces = line[2..-1].collect(&:to_i)
        elsif ordinal_num != 0
          begin
            date,time = line[0].split('-').collect(&:strip)
            jd_params = date.split('/').collect(&:to_i)
            s_time = time.split(':').collect(&:to_i)
            gd = JalaliDate.new(*jd_params).to_g
            @dates[ordinal_num] = DateTime.new gd.year, gd.month, gd.day, s_time[0], s_time[1], s_time[2]
            @imported_data[ordinal_num] = line[2..-1]
          rescue
          end
        end
      end
      @sensors = Sensor.where(channel_index: @sensor_indeces).group_by(&:channel_index)
      @client.values.where(sample_ordinal_num: @imported_data.keys, channel_index: @sensor_indeces).delete_all
      conn = ActiveRecord::Base.connection
      rc = conn.raw_connection
      rc.exec "COPY sample_values (client_id,sample_ordinal_num,channel_index,value,sample_time,sensor_id) FROM STDIN WITH CSV"
      @imported_data.each do |ordinal_num, row|
        row.each_with_index do |value, index|
          begin
            channel_index = @sensor_indeces[index]
            sensor = @sensors[channel_index][0]
            date = @dates[ordinal_num]
            rc.put_copy_data "#{@client.id},#{ordinal_num},#{channel_index},#{value},'#{date.strftime("%Y-%m-%d %H:%M:%S")}',#{sensor.id}\n"
          rescue
          end
        end
      end
      rc.put_copy_end
      while res = rc.get_result
        if e_message = res.error_message
          my_logger.debug ">>PG: #{e_message[0..50]+(e_message.length > 50 ? '...' : '')}"
        end
      end
      flash.now[:notice] = "با موفقیت ایمپورت شد"
    else
      flash.now[:notice] = "فایل انتخاب نشده است"
    end
    # redirect_to import_client_path(@client)
    render 'import'
  end

  def export
    set_client

    @sensors = @client.sensors.where(channel_index: params[:channel]).to_a
    gsensors = @sensors.group_by(&:channel_index)

    @first_value = @client.values.where(channel_index: @client.sensors.pluck(:channel_index)).first

    begin
      @from = JalaliDate.new( *(params[:from].split('/').collect(&:to_i))) if params[:from]
      @to = JalaliDate.new( *(params[:to].split('/').collect(&:to_i))) if params[:to]
    rescue ArgumentError
    end


    return if not @from or not @to
    # return flash.now[:error] = "ابتدای بازه انتخاب نشده است." unless @from
    # return flash.now[:error] = "انتهای بازه انتخاب نشده است." unless @to

    
    from_g = @from.to_g.to_datetime.in_time_zone("Tehran").at_beginning_of_day
    to_g = @to.to_g.to_datetime.in_time_zone("Tehran").at_end_of_day
    first_value = @client.values.where(channel_index: gsensors.keys, sample_time: from_g..to_g).first
    last_value = @client.values.where(channel_index: gsensors.keys, sample_time: from_g..to_g).last
    
    return flash.now[:error] = "بازه انتخاب شده اشتباه می باشد." unless from_g <= to_g
    return flash.now[:error] = "هیچ داده‌ای در این بازه وجود ندارد" unless first_value
    
    if to_g > first_value.sample_time
      to_g = first_value.sample_time
      @to = JalaliDate.new to_g
    end
    if from_g < last_value.sample_time
      from_g = last_value.sample_time
      @from = JalaliDate.new from_g
    end

    limit = 200000
    
    query_size = @client.values.where(channel_index: gsensors.keys, sample_time: from_g..to_g).count
    lo = from_g
    hi = to_g
    mid = lo
    cnt = 0

    # my_logger.info "query_size: #{query_size}   limit: #{limit}"

    if query_size > limit
      flash.now[:error] = "داده‌های دوره‌ی درخواست شده غیر قابل پردازش است." 
      while 1000 < (query_size-limit).abs
        cnt += 1
        mid = Time.at((lo.to_i+hi.to_i)/2).to_datetime
        from_g = mid
        @from = JalaliDate.new from_g
        
        query_size = @client.values.where(channel_index: gsensors.keys, sample_time: from_g..to_g).count
        
        if query_size > limit
          lo = mid
        elsif query_size < limit
          hi = mid
        end
        
        my_logger.info "#{cnt}: #{mid} --- #{query_size}"
      end
    end


    # limit = 500000
    # if (to_g.to_i - from_g.to_i) / @client.sampling_time > limit
    #   from_g = to_g - (limit*@client.sampling_time).seconds
    #   @from = JalaliDate.new from_g
    #   flash.now[:error] = "داده‌های دوره‌ی درخواست شده غیر قابل پردازش است." 
    # end

    exported = @client.export(from_g, to_g, @sensors)
    
    return send_data exported, disposition: :inline, filename: "export-#{@client.name}-#{Time.now}.csv"

  rescue ArgumentError
  # rescue
  #   render text: 'error'
  end

  def export_standard
    set_client

    # my_logger.info "export_standard: #{Time.now}"

    sensors = @client.sensors
    gsensors = sensors.to_a.group_by(&:channel_index)

    @first_value = @client.values.first
    
    begin
      @from = JalaliDate.new( *(params[:from].split('/').collect(&:to_i))) if params[:from]
      @to = JalaliDate.new( *(params[:to].split('/').collect(&:to_i))) if params[:to]
    rescue ArgumentError
    end

    return if not @from or not @to
    # return flash.now[:error] = "ابتدای بازه انتخاب نشده است." unless @from
    # return flash.now[:error] = "انتهای بازه انتخاب نشده است." unless @to
    
    from_g = @from.to_g.to_datetime.in_time_zone("Tehran").at_beginning_of_day
    to_g = @to.to_g.to_datetime.in_time_zone("Tehran").at_end_of_day
    first_value = @client.values.where(sample_time: from_g..to_g).first
    last_value = @client.values.where(sample_time: from_g..to_g).last
    
    return flash.now[:error] = "بازه انتخاب شده اشتباه می باشد." unless from_g <= to_g
    return flash.now[:error] = "هیچ داده‌ای در این بازه وجود ندارد" unless first_value
  
    if to_g > first_value.sample_time
      to_g = first_value.sample_time
      @to = JalaliDate.new to_g
    end
    if from_g < last_value.sample_time
      from_g = last_value.sample_time
      @from = JalaliDate.new from_g
    end

    limit = 200000
    
    query_size = @client.values.where(channel_index: gsensors.keys, sample_time: from_g..to_g).count
    lo = from_g
    hi = to_g
    mid = lo
    cnt = 0

    # my_logger.info "query_size: #{query_size}   limit: #{limit}"

    if query_size > limit
      flash.now[:error] = "داده‌های دوره‌ی درخواست شده غیر قابل پردازش است." 
      while 1000 < (query_size-limit).abs
        cnt += 1
        mid = Time.at((lo.to_i+hi.to_i)/2).to_datetime
        from_g = mid
        @from = JalaliDate.new from_g
        
        query_size = @client.values.where(channel_index: gsensors.keys, sample_time: from_g..to_g).count
        
        if query_size > limit
          lo = mid
        elsif query_size < limit
          hi = mid
        end
        
        my_logger.info "#{cnt}: #{mid} --- #{query_size}"
      end
    end

    exported = @client.export(from_g, to_g, sensors, true)
    
    return send_data exported, disposition: :inline, filename: "export-standard-#{@client.name}-#{Time.now}.csv"

    rescue ArgumentError
  end

  def export_shown_data
    if @client and
       params.has_key?(:from) and
       params.has_key?(:to) and
       params.has_key?(:channel) and
       params.has_key?(:range_selector) and
       params.has_key?(:average)

      sensors = @client.sensors.where(channel_index: params[:channel]).to_a
      gsensors = sensors.group_by(&:channel_index)

      begin
        @from = JalaliDate.new( *(params[:from].split('/').collect(&:to_i))) if params[:from]
        @to = JalaliDate.new( *(params[:to].split('/').collect(&:to_i))) if params[:to]
      rescue ArgumentError
      end

      return if not @from or not @to
      
      from_g = @from.to_g.to_datetime.in_time_zone("Tehran").at_beginning_of_day
      to_g = @to.to_g.to_datetime.in_time_zone("Tehran").at_end_of_day
      range_selector = params[:range_selector].to_i
      average = params[:average].to_i

      exported = @client.export_shown_data(from_g, to_g, sensors, range_selector, average)
    
      return send_data exported, disposition: :inline, filename: "shown-data-#{@client.name}-#{Time.now}.csv"
    end
    rescue ArgumentError
  end

  def export_live_data
    if @client and
       params.has_key?(:from) and
       params.has_key?(:sensor)

      sensor = @client.sensors.where(channel_index: params[:sensor]).first

      begin
        @from = params[:from].to_datetime
      rescue ArgumentError
      end

      return if not @from
      
      from_g = @from.in_time_zone("Tehran")
      to_g = @client.values.where(channel_index: params[:sensor]).first.sample_time.to_datetime.in_time_zone("Tehran")

      exported = @client.export_live_data(from_g, to_g, sensor)
    
      return send_data exported, disposition: :inline, filename: "live-data-#{@client.name}-#{sensor.name}-#{Time.now}.csv"
    end
    rescue ArgumentError
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params(update_params=false)
      _ret = params.require(:client).permit(:ordinal_num, :sampling_time, :samples_count, :operator_id, :client_info_id)
      unless current_user.higher_than? :admin
        _ret.delete :operator_id
        _ret.delete :client_info_id
      end
      if update_params
        _ret.delete :client_info_id
      end
      _ret
    end
end
