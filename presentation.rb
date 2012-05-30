# == ActiveSupport Presentation
#
# ActiveSupport is the 2nd most popular gem in the world [RubyGems Stats](https://rubygems.org/stats)
#
# Today, we are going to learn what's in it, how you are already using it in your Rails apps and
# how you can use is to write better Rails apps.
#
# This talk is going to be very fast paced.  I'm going to try and get through as much as possible.  I want
# you to be able to walk away from this talk with a couple of really good ideas on how to improve your Rails app.
#
# What the heck *is* ActiveSupport?  It's the only entirely cross cutting dependency in Rails.  Every library uses it: ActiveRecord, ActionPack, ActiveModel, etc.
# It includes 2 different parts, the core extensions, and modules. We're going to start by looking at some cool core extensions. These are changes to the Ruby language or standard
# library
#
# === in_groups_of
#
# How many times has your designer handed you some HTML to code that looks like this:
#
# ```html
# <ul>
#   <li>Item 1</li>
#   <li>Item 2</li>
#   <li>Item 3</li>
# </ul>
#
# <ul>
#   <li>Item 4</li>
#   <li>Item 5</li>
#   <li>Item 6</li>
# </ul>
#
# <ul>
#   <li>Item 7</li>
#   <li>Item 8</li>
#   <li>Item 9</li>
# </ul>
# ```
#
# And you think to yourself, thanks designer, now I'm going to have to write some really ugly ERB code to
# get this to work. Y U NO USE ONE UL?
# 
# ```html
# <% items1 = @items[0..2] %>
# <ul>
#   <% items1.each do |item| %>
#     <li><%= item.name %></li>
#   <% end %>
# </ul>
#
# <% items2 = @items[3..5] %>
# <ul>
#   <% items2.each do |item| %>
#     <li><%= item.name %></li>
#   <% end %>
# </ul>
# ```
#
# `in_groups_of` extends `Array` to make this sort of thing easier:
#
# ```html
# <% @items.in_groups_of(3) do |group| %>
#   <ul>
#     <% group.each do |item| %>
#       <% if item %>
#         <li><%= item.name %></li>
#       <% end %>
#     <% end %>
#   </ul>
# <% end %>
# ```
#
# This allows us to have 2 loops, the top one loops through each group of 3 items,
# and the inner one loops through the items in the group.
#
# === try
#
# How many times have you deployed new code, and within 5 minutes Airbrake starts reporting an error like this:
# 
# `ActionView::Template::Error (undefined method `name' for nil:NilClass)`
#
# All sorts of scenarios could cause this error: maybe someone is fiddling around with the URL and enters an ID that doesn't exist.  But you'd
# rather not be clogging up your Airbrake.  You could write code like this everywhere:
#
# <%= @item.name if @item.present? %>
#
# But then what if you want to chain calls, like this:
#
# <%= @item.name.truncate(20) %>
#
# <%= @item && @item.name && @item.name.truncate(20) %>
#
# `try` cleans up this code considerably, and makes your application a little bit more resistent to NoMethodErrors:
#
# <%= @item.try(:name).try(:truncate, 20) %>
#
# `try` will return `nil` if `@item` is nil.
#
# === reverse_merge
#
# If you've looked at the Rails source, you were likely to see calls the `reverse_merge` everywhere.
#
# `reverse_merge` is used frequently in rails methods that take an options hash (like `form_tag`) to setup defaults
# for that options hash.
#
def form_tag(url, options={})
  options[:method] = "POST" if options[:method].blank?
  options[:action] = current_path if options[:action].blank?
end

# Instead:
def form_tag(url, options={})
  options = options.reverse_merge(method: "POST", action: current_path)
end

# == indifferent_access
#
# Almost all the string-keyed hashes we encounter in Rails can be accessed like so:
params[:item]

# or 
params["item"]

# And we don't really have to worry about using symbols or strings, both work!  But as soon as you create your own hash, things can go wrong:
options = { :foo => "bar" }

puts options["foo"] #=> nil

# You can use `indifferent_access` to make hashes work like they do in rails:
options = { :foo => "bar" }.with_indifferent_access

puts options["foo"] #=> "bar"

# === except
#
# Ever want to filter out certain items in a params hash before calling update_attributes or create? You could write code like this:

def update
  params[:user].delete(:admin)
  params[:user].delete(:impersonate)

  @user.update_attributes params
end

# Use `except` to filter out keys, and it has the added benefit of working with indifferent access:
def update
  @user.update_attributes params.except(:admin, :impersonate)
end

# this is the "blacklist" approach, but you can use another core extension to only allow certain keys in the hash using `slice`:
def update
  @user.update_attributes params.slice(:name, :email)
end

# === String#truncate
#
# Let's say you are using Postgres and have a string column on a column named short_description that should be at most 255 characters.  In your model, you want to make
# sure a string larger than 255 characters is never set on short_description.  You can use `truncate` to do this:

class Item < ActiveRecord::Base
  def short_description=(new_short_description)
    super new_short_description.truncate(255)
  end
end

short_description = %{
  Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
  Mauris id enim vel ipsum porta vestibulum. Etiam ultrices malesuada est sed iaculis. 
  Donec mattis luctus dui, congue adipiscing tortor molestie et. 
  Nunc volutpat urna id ante rhoncus sit amet mollis odio placerat. Quisque porta tincidunt amet
}
item = Item.new(short_description: short_description)
puts item.short_description

# Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
# Mauris id enim vel ipsum porta vestibulum. Etiam ultrices malesuada est sed iaculis. 
# Donec mattis luctus dui, congue adipiscing tortor molestie et. Nunc volutpat urna id ante rhoncus sit amet mol...

# You can change the "..." by passing in the `omission` option:

class Item < ActiveRecord::Base
  def short_description=(new_short_description)
    super new_short_description.truncate(255, omission: " (continued)")
  end
end


# === Time
#
# Have you ever used `Time.now`?  A quick grep of a recent project might find `Time.now` scattered all over the place.  YOU WILL REGRET EVER USING THIS.
#
# As soon as you introduce the concept of TimeZones into your application, `Time.now` will break. Time.now returns a time based on the timezone on the machine.
# 
# Instead of `Time.now`, always use `Time.current`:

[1] pry(main)> Time.zone
=> (GMT+00:00) UTC
[2] pry(main)> Time.now
=> 2012-05-30 12:38:27 -0400
[3] pry(main)> Time.current
=> Wed, 30 May 2012 16:38:30 UTC +00:00
[4] pry(main)> Time.zone = "Hawaii"
=> "Hawaii"
[5] pry(main)> Time.current
=> Wed, 30 May 2012 06:38:37 HST -10:00
[6] pry(main)> Time.now
=> 2012-05-30 12:38:39 -0400

# Time Zones are really easy to use in your Rails applications thanks to ActiveSupport.  First, give the user the ability to select their time zone:

# use the time_zone_select helper (http://cl.ly/1h1C3w0o1H0I1C2T1y1t)
<%= time_zone_select( "user", "time_zone", ActiveSupport::TimeZone.all.sort, :model => ActiveSupport::TimeZone) %>


# Then, before after action, make sure you set the time for the user
class ApplicationController < ActionController::Base

  around_filter :set_time_zone

  private
  
  def set_time_zone(&block)
    return unless logged_in?

    Time.use_zone(current_user.time_zone, &block)
  end
end

# === Time#to_formatted_s
#
# How many times do you have a created_at timestamp in your rails application and you want to output it to the view with a certain format, and you
# have to go look up the strftime docs *once again*.  Well, AS defines a method for outputting several common datetime formats, without having to
# remember all those % strftime shorthands.


> user.created_at
=> Wed, 30 May 2012 16:50:45 UTC +00:00
> user.created_at.to_formatted_s :short
=> "30 May 16:50"
> user.created_at.to_formatted_s :long
=> "May 30, 2012 16:50"
> user.created_at.to_formatted_s :time
=> "16:50"

# You can easily add your own date formats to use throughout your app.  Add a `config/initializers/formats.rb` file:

Time::DATE_FORMATS[:month_and_year] = "%B %Y"

# Now in your app you can use it:
> user.created_at.to_formatted_s :month_and_year
=> "May 2012"

# == to_xml and to_json
#
# You don't need ActiveRecord objects to take advantage of `to_xml` and `to_json`. ActiveSupport defines both these methods on all core ruby classes. 
# So if you just had an array of hashses, you could do this:
> posts = [
 {id: 1, title: "Foo"},
 {id: 2, title: "Bar"}
]  

> puts posts.to_xml

<?xml version="1.0" encoding="UTF-8"?>
<objects type="array">
  <object>
    <id type="integer">1</id>
    <title>Foo</title>
  </object>
  <object>
    <id type="integer">2</id>
    <title>Bar</title>
  </object>
</objects>

> puts posts.to_xml root: "posts"

<?xml version="1.0" encoding="UTF-8"?>
<posts type="array">
  <post>
    <id type="integer">1</id>
    <title>Foo</title>
  </post>
  <post>
    <id type="integer">2</id>
    <title>Bar</title>
  </post>
</posts>

> puts posts.to_json root: "posts"
[{"id":1,"title":"Foo"},{"id":2,"title":"Bar"}]

# Which means you can render a hash or an array just like you would a ActiveRecord objects in your controller

def show
  posts = [
   {id: 1, title: "Foo"},
   {id: 2, title: "Bar"}
  ]  

  render json: posts
end

# === Array#to_sentence
#
# Never use Array#join if you don't have to.  Your users won't be pleased reading this:

> post.tags.join(", ")
=> "ruby, rails, web, http"
> tags.to_sentence
=> "ruby, rails, web, and http"

# Don't like the oxford comma?
> tags.to_sentence last_word_connector: " and "
=> "ruby, rails, web and http"


# === Wrap up of Core Ext
#
# Where can you find these core extensions? In the source: (include directory structure)
#
# == The Rest of ActiveSupport
#
# === ActiveSupport::Notifications
#
# Rails exposes a ton of information about it's performance and with Notifications you can subscribe to this performance
# instrumentation, or you could even instrument your own code.  When attempting to scale an application, data is critically
# important.  If you can't measure it, you can't improve it.  Notifications allow you to measure everything, and provides a really
# nice interface for listening.
#
# Let's look at ActiveRecord sql queries as a first step into notifications:

# `config/initializers/subscribers.rb`
ActiveSupport::Notifications.subscribe("sql.active_record") do |*args|
  event = ActiveSupport::Notifications::Event.new *args

  Rails.logger.info "(#{event.duration}) #{event.payload[:sql]}"
end

# Which will log a bunch of things that look like this:
#
# Started GET "/posts/1" for 127.0.0.1 at 2012-05-30 15:49:19 -0400
#
# (1.57) PRAGMA table_info("users")
# (0.156) SELECT name FROM sqlite_master WHERE type = 'table' AND NOT name = 'sqlite_sequence' AND name = "users"
# (0.078) PRAGMA table_info("users")
# (0.13899999999999998) SELECT "users".* FROM "users" LIMIT 1
# (0.14400000000000002) PRAGMA table_info("posts")
# (0.182) SELECT name FROM sqlite_master WHERE type = 'table' AND NOT name = 'sqlite_sequence' AND name = "posts"
# (0.098) PRAGMA table_info("posts")
# (0.255) SELECT "posts".* FROM "posts" WHERE "posts"."id" = ? LIMIT 1
#
# Hey look, we are logging all of our SQL queries and how long they took to run!
#
# In fact, this is the same mechanism that ActiveRecord uses to log it's queries in development mode.
#
# The `"sql.active_record"` string specifies which events to listen to. `sql` is scoping the `active_record` namespace, but if we want
# we could listen to all the active_record instruments:
ActiveSupport::Notifications.subscribe(/action_controller/) do |*args|
  event = ActiveSupport::Notifications::Event.new *args

  Rails.logger.info "(#{event.duration}) #{event.name}"
end

# Started GET "/posts/1" for 127.0.0.1 at 2012-05-30 15:49:19 -0400
#
# (0.004) start_processing.action_controller
# (265.583) process_action.action_controlle
#
# Or we could listen to everything:
ActiveSupport::Notifications.subscribe do |*args|
  event = ActiveSupport::Notifications::Event.new *args

  Rails.logger.info "(#{event.duration}) #{event.name}"
end

# Started GET "/posts/1" for 127.0.0.1 at 2012-05-30 15:49:19 -0400
#
# (0.004) start_processing.action_controller
# Processing by PostsController#show as HTML
# (1.588) sql.active_record
# (0.154) sql.active_record
# (0.078) sql.active_record
# (0.128) sql.active_record
# (0.17300000000000001) sql.active_record
# (0.17200000000000001) sql.active_record
# (0.11) sql.active_record
# (0.285) sql.active_record
# (71.84599999999999) !render_template.action_view
# (72.021) render_template.action_view
# (62.852000000000004) !render_template.action_view
# (195.006) process_action.action_controller
#
# What if we wanted to record each request to our Rails app in the database, along with helpful information about each request.
#
# We could just listen to the 'process_action.action_controller' event, and create a PageRequest record for each event:

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

# http://cl.ly/1r0H1o103F3F2s1Y0P3Q
#
# You can easily instrument and subscribe to your own custom instruments
#
# For example, in codeschool, one of our major pieces of functionality is "running" somebody's code that they submitted.
# It's important this is fast, or our student might get bored and decide to play minecraft or something.
require 'active_support/notifications'

class CodeSchoolRunner
  def run!(code)
    ActiveSupport::Notifications.instrument('run.codeschool', code: code, challenge: name) do
      # run the challenge here
    end
  end
end

# And then elsewhere, we can subscribe to the `run.codeschool` event and save information to a Redis stats server:
require 'redis'
redis = Redis.new

ActiveSupport::Notifications.subscribe('run.codeschool') do |*args|
  event = ActiveSupport::Notifications::Event.new *args

  redis.hincrby("codeschool:run_counts", event.payload[:challenge], 1)
  redis.hincrby("codeschool:run_total_durations", event.payload[:challenge], event.duration)
end

# Or you could use Statsd (https://github.com/noahhl/batsd)

# And, in another part of my application, I can subscribe to the same event, but this time report the run to newrelic
require 'newrelic_rpm'

ActiveSupport::Notifications.subscribe("run.codeschool") do |*args|
  event = ActiveSupport::Notifications::Event.new *args
  stat = NewRelic::Agent.agent.stats_engine.get_stats_no_scope("Custom/Challenge/run")
  stat.record_data_point(event.duration / 1000.0)
end

