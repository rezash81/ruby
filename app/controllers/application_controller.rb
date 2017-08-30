class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # around_filter :disable_gc

  def persian_numbers(str)
    str ? str.to_s.unpack('U*').map{ |e| (0..9).to_a.include?(e-48) ? e + 1728 : e }.pack('U*') : ''
  end

  def my_logger
    @@my_logger ||= Logger.new("#{Rails.root}/log/my.log")
  end

  rescue_from 'ActionController::RoutingError' do
    render text: ''
  end


private
  # def disable_gc
  #   GC.disable
  #   begin
  #     yield
  #   ensure
  #     GC.enable
  #     GC.start
  #   end
  # end
end
