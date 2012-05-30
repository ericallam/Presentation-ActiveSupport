# ActiveSupport::Notifications.subscribe do |*args|
#   event = ActiveSupport::Notifications::Event.new *args

#   Rails.logger.info "[#{event.transaction_id}] (#{event.duration}) #{event.name} PAYLOAD: #{event.payload.inspect}"
#   #<ActiveSupport::Notifications::Event:0x007faba364b238 @name="start_processing.action_controller", @payload={:controller=>"PostsController", :action=>"show", :params=>{"action"=>"show", "controller"=>"posts", "id"=>"1"}, :format=>:html, :method=>"GET", :path=>"/posts/1"}, @time=2012-05-30 14:11:59 -0400, @transaction_id="93ed7a14722491131548", @end=2012-05-30 14:11:59 -0400, @duration=0.005>
# end
# ActiveSupport::Notifications.subscribe("sql.active_record") do |*args|
#   event = ActiveSupport::Notifications::Event.new *args

#   Rails.logger.info "(#{event.duration}) #{event.payload[:sql].squish}"
# end
ActiveSupport::Notifications.subscribe("process_action.action_controller") do |*args|
  event = ActiveSupport::Notifications::Event.new *args

  PageRequest.new.tap do |page|
    page.status = event.payload[:status]
    page.http_method = event.payload[:method]
    page.path = event.payload[:path]
    page.http_format = event.payload[:format]
    page.controller_name = event.payload[:controller]
    page.action_name = event.payload[:action]
    page.view_runtime = event.payload[:view_runtime]
    page.db_runtime = event.payload[:db_runtime]
    page.duration = event.duration
    page.save!
  end
end
# ActiveSupport::Notifications.subscribe do |*args|
#   event = ActiveSupport::Notifications::Event.new *args

#   Rails.logger.info "(#{event.duration}) #{event.name}"
# end
