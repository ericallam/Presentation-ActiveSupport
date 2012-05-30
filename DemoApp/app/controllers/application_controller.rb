class ApplicationController < ActionController::Base
  protect_from_forgery

  around_filter :set_time_zone
  # around_filter :subscribe_to_action

  private

  def subscribe_to_action(&block)
    @events = []

    callback = lambda do |*args|
      @events << ActiveSupport::Notifications::Event.new(*args)
    end

    ActiveSupport::Notifications.subscribed(callback, &block)

    @events.each do |event|
      Rails.logger.info "[#{event.transaction_id}] (#{event.duration}) #{event.name} PAYLOAD: #{event.payload.inspect}"
    end
  end
  
  def set_time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end

  def current_user
    User.first
  end
end
