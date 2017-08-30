class SensorsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_sensor, only: [:show, :edit, :update, :destroy]
  before_action {@app = true}
  before_action {@tab = 'sensor'}

  def index
    @sensors = Sensor.all
  end

  def show
  end

  def new
    @sensor = Sensor.new
  end

  def edit
  end

  def create
    @sensor = Sensor.new(sensor_params)

    if @sensor.save
      redirect_to @sensor, notice: 'Sensor was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @sensor.update(sensor_params)
      redirect_to @sensor, notice: 'Sensor was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @sensor.destroy
    redirect_to sensors_url
  end

  private
    def set_sensor
      @sensor = Sensor.find(params[:id])
    end

    def sensor_params
      params.require(:sensor).permit(:client_ordinal_num, :channel_index, :measure_unit, :code, :unit_code, :unit_avb,
                                     :saving_type, :channel_type, :hw_port_type, :hw_port_number, :hw_port_pin_number,
                                     :calculation_type, :is_active, :calibration_table_bin, :name, :description, :channel_index)
    end
end
