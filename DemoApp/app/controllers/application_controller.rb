require 'open-uri'

class ApplicationController < ActionController::Base
  protect_from_forgery

  around_filter :set_time_zone
  # around_filter :subscribe_to_action
  
  before_filter :fetch_tweets

  private

  def fetch_tweets
    @tweets = Rails.cache.fetch "companytweets", expires_in: 5.minutes, race_condition_ttl: 5.seconds do
      JSON.parse(open('http://api.twitter.com/1/statuses/user_timeline.json?include_entities=true&screen_name=codeschool').read)
    end
  end

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
