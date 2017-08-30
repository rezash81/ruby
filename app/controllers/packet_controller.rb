require 'uri'
require 'net/http/post/multipart'

class PacketController < ApplicationController
  skip_before_action :verify_authenticity_token
  def recieve
    # my_logger.info ">>>>RECIEVE METHOD (Packet Controller)"
    # puts ">> GUID: #{cookies[:Client_GUID]}"
    session_start
    if cookies[:Client_RequestType]
      if handshake
        if authenticate_client
          if cookies[:Client_RequestType].to_i == 1
            if params[:DataLog_Packet]
              @dataLog_Packet = params[:DataLog_Packet]
              @str = @dataLog_Packet.length.to_s
              @f_name = "/tmp/packet#{rand(20000)}.log"
              File.write(@f_name, @dataLog_Packet)
              if parsePacket @dataLog_Packet
                @str += send_request cookies[:Client_RequestType], 0, -1, "", -1, "Packet parse ok"
                send_to_second_server
              else
                @str += send_request cookies[:Client_RequestType], -1, -1, "", -1, ""
              end
              File.delete(@f_name)
            end
          end
        end
      elsif cookies[:Client_RequestType].to_i == 0
        @str = send_request(cookies[:Client_RequestType], 0, -1, "", -1, "new HandShaked Request")
      else
        @str = send_request(cookies[:Client_RequestType], 1, -1, "", 0, "Session Expired")
      end
    end
    render text: @str || ''
    # puts "#{@str}" #debug request sent!
  end

  def post_to_second_server url, http
    status = false
    begin
      File.open @f_name do |file|
        dataLog_Packet = UploadIO.new(file, "application/octet-stream", "data.log")
        req = Net::HTTP::Post::Multipart.new url.path, packet: dataLog_Packet, guid: @client.guid
        resp = http.request req
        # my_logger.info "#{resp.body}"
      end
      status = true
    rescue
    end
    return status
  end

  def send_to_second_server
    second_host = @client.static_ip
    begin
      if second_host and second_host != ''
        done = false
        url = URI.parse "http://#{second_host}#{second_server_post_path}"
        http = Net::HTTP.new(url.host, url.port)
        http.read_timeout = 3
        3.times do
          if not done
            done = post_to_second_server url, http
            if done
              my_logger.info "success"
            else
              my_logger.info "failed"
            end
          end
        end
      end      
    rescue
    end
  end

  def second_recieve
    @str = "fail"
    if params[:guid] and params[:packet]
      @client = ClientInfo.where(guid: params[:guid]).first
      if @client
        @dataLog_Packet = params[:packet]
        @f_name = "/tmp/packet#{rand(20000)}.log"
        File.write(@f_name, @dataLog_Packet)
        if parsePacket @dataLog_Packet
          @str = "done"
        end
        File.delete(@f_name)
      end
    end
    render text: @str
  end

  private
    def send_request(actionType, actionResultType, commandType, contentStr, errorCode, errorStr)
      "Server_ActionType=#{actionType}&" + "Server_ActionResultType=#{actionResultType}&" + "Server_CommandType=#{commandType}&" +
      "Server_ContentStr=#{contentStr}&" + "Server_ErrorCode=#{errorCode}&" + "Server_ErrorStr=#{errorStr}&"
    end

    def authenticate_client
      # my_logger.info ">> authenticate_client"
      if session[:Client_GUID]
        return true
      elsif cookies[:Client_GUID]
        @client = ClientInfo.where(guid: cookies[:Client_GUID]).first
        if @client
          session[:Client_GUID] = @client.guid
          return true
        else
          @str = send_request(cookies[:Client_RequestType], 1, -1, "", 4, "Client GUID Not Found")
        end
      end
      return false
    end

    def handshake
      # my_logger.info ">>>>> Handshake"
      if cookies[:PHPSESSION_ID_Reversed]
        # puts ">>>>>SESION: #{session[:PHPSESSID].reverse}"
        # puts ">>>>>SESION: #{session[:PHPSESSID]}"
        if cookies[:PHPSESSID] and cookies[:PHPSESSION_ID_Reversed] == cookies[:PHPSESSID].reverse
          return true
        end
      end
      return false
    end

    def session_start
      # puts ">>>>>>PREVIOUS: #{session[:PHPSESSID]}"
      unless cookies[:PHPSESSID]
        cookies[:PHPSESSID] = { :value => SecureRandom.hex, :expires => 1.hour.from_now }
      end
    end

    def parsePacket(packet)
      returnValue = true
      # my_logger.info ">>>>> ParsePacket"
      result = `bin/packet_parser #{@f_name}`
      # puts ">> #{result}"
      samples = result.split("\n").collect{|sample| sample.split(',')}
      sensors = Sensor.all
      clients = @client.clients.to_a
      # begin
        ActiveRecord::Base.transaction do
          # my_logger.info ">>>>> count #{samples.count}"
          samples.each do |sample|
            clientConfigOrdinalNum = sample[0].to_i
            # my_logger.info ">>>>> ordinal_num #{clientConfigOrdinalNum}"
            client = clients.find{|c| c.ordinal_num == clientConfigOrdinalNum}
            if client
              sampleOrdinalNum = sample[1].to_i
              sampleYear = sample[2].to_i
              sampleMonth = sample[3].to_i
              sampleDay = sample[4].to_i
              sampleHour = sample[5].to_i
              sampleMin = sample[6].to_i
              sampleSec = sample[7].to_i
              date = Time.zone.parse("#{sampleYear}-#{sampleMonth}-#{sampleDay} #{sampleHour}:#{sampleMin}:#{sampleSec}")
              client.samples.create ordinal_num: sampleOrdinalNum, client_ordinal_num: clientConfigOrdinalNum, sample_time: date.to_datetime
              channel_count = sample[8].to_i
              # my_logger.info "channel_count #{channel_count}"
              channel_count.times do |i|
                channel_index = sample[i*2+9].to_i
                # my_logger.info "( channel_index: #{channel_index} )"
                sensor = sensors.find{|s| s.channel_index == channel_index}
                value = sample[i*2 + 10].to_f
                sample_value = client.values.build sample_ordinal_num: sampleOrdinalNum, channel_index: channel_index, value: value, sample_time: date
                sample_value.sensor = sensor if sensor
                sample_value.save
              end
            else
              my_logger.info "( Wrong Ordinal Num => #{clientConfigOrdinalNum})"
              returnValue = false
            end
          end
        end
      return returnValue
    end

end
 