class ApplicationController < ActionController::Base
  protect_from_forgery

  around_filter :set_time_zone

  private
  
  def set_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  def current_user
    User.first
  end
end
