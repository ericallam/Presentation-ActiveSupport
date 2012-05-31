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

# === Array#forty_two
#
# Ever have a really long array, and you really want to get the forty second element, and are forced to do this:
> array[41]
#=> "Foo"

# Well that's a PIA.  AS has a little something for you:
> array.forty_two
#=> "Foo"


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

# and then we can create a custom view in newrelic to report this information:
#
# http://cl.ly/0l2X233P091o1X0V1w34


# === Cache
#
# Have you ever written your own cacheing mechanism in your Rails app?  At first you cache everything to memcache, but
# then you realize you don't want to use memcache on development, so you write an abstract cache store, etc etc.
#
# Well, you just wasted a lot of time, because ActiveSupport comes with a caching implementation called ActiveSupport::Cache, that
# has stores for memory, file, memcache, and allows you to easily write custom cache stores.
#
# Cache provides an abstract interface, so you can use different cache stores without having to change anything.
#
# Get access to the current cache store:
Rails.cache

# In development, by default the cache store is the FileStore
> Rails.cache.class
=> ActiveSupport::Cache::FileStore

# Cache::Store has a pretty simple interface, and you usually only need to use `#fetch`.  
Rails.cache.fetch("http://www.codeschool.com") { open("http://www.codeschool.com").read }

# If `#fetch` doesn't find the key, it will execute the block and store the return value in the key.  So the first
# time this is called, it will go out and make an http request.  The second time it is called, it will just return
# the value from the store.  This makes it easy to cache http requests that could slow down your request/response time.
#
# You can also pass options to `#fetch` to set an expiration of the cache, this way content will be refreshed every minute:
Rails.cache.fetch("http://www.codeschool.com", expires_in: 1.minute) { open("http://www.codeschool.com").read }

# If you pass an "expires_in" option, you should also specify the `race_condition_ttl` option.  Using this option will prevent cache "dog-piling",
# when many servers try to write to the cache at the same time, right after the key expires.  So the first server who encounters the
# expired key will increase it's expire time by the `race_condition_ttl`, and all the other servers will still recieve the old value, while the first
# server regenerates the value for the key.  As soon as the new value is set on the key, all the other servers will get the new value. The key
# is to keep the race_condition_ttl small.
Rails.cache.fetch("http://www.codeschool.com", expires_in: 1.minute, race_condition_ttl: 5.seconds) { open("http://www.codeschool.com").read }

# A common problem that ActiveSupport::Cache can solve is something like: you have a sidebar in your application that shows the latest 5 tweets from
# your company twitter account. At first, you create a before_filter in your ApplicationController to fetch the tweets on every request:
require 'open-uri'

class ApplicationController < ActionController::Base

  before_filter :fetch_tweets

  private

  def fetch_tweets
    @tweets = JSON.parse(open('http://api.twitter.com/1/statuses/user_timeline.json?include_entities=true&screen_name=codeschool').read)
  end
end

# But now on every request we are spending precious time going over the network to hit twitter.com.  And we don't need to have the tweets up to the second
# of the request.  Maybe we only want them to refresh every 5 minutes. We can use the Cache to do that easily:
def fetch_tweets
  @tweets = Rails.cache.fetch "companytweets", expires_in: 5.minutes, race_condition_ttl: 5.seconds do
    JSON.parse(open('http://api.twitter.com/1/statuses/user_timeline.json?include_entities=true&screen_name=codeschool').read)
  end
end

# So the first request is slow, but subsequent requests are fast: (http://cl.ly/0Z2z3K0O0Q2o1e1h0e1q)
#
# Changing stores. It's really easy to have different stores in different environements.  In test and development, it's probably a good idea to use the NullStore:

# in `config/application.rb`
module DemoApp
  class Application < Rails::Application
    ...

    config.cache_store = :null_store
  end
end

# In production, you'll probably want to use something like MemcacheStore (heroku has a free memcache addon with 5mb of cache space).
#
# in `config/environments/production.rb`
DemoApp::Application.configure do
  ...
  config.cache_store = :mem_cache_store, "cache-1.example.com", "cache-2.example.com"
end

# You can use stores that haven't been bundled with rails.  For example, if you want to use redis, you can use the `redis-rails` gem:

# in `Gemfile`
gem 'redis-rails'

# in `config/application.rb`
config.cache_store = :redis_store

# http://cl.ly/0J3Q0K3y2f2Q402c3h3x
#
# Cascade store: https://github.com/jch/activesupport-cascadestore
#
# === Lazy Load
#
# ActiveSupport lazy_load_hooks is one of the first files to get required when loading rails.  It allows pieces of the Rails framework
# to register hooks to run when other parts of the framework are loaded.  For example, when ActiveRecord::Base has finished loading, it 
# notifies ActiveSupport and tells it to run all hooks for `active_record`.  It looks like this:
#
ActiveSupport.run_load_hooks(:active_record, ActiveRecord::Base)

# The second argument becomes the context for the hook when it is run.  You can add a hook like this:
ActiveSupport.on_load(:active_record) do
  # in here `self` is ActiveRecord::Base
end

# In fact, this is how the `config/initializers/wrap_parameters.rb` file sets the `include_root_in_json` attribute on ActiveRecord::Base:
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end

# ActiveSupport will run any `on_load` that have been added, even if they were added after the `run_load_hooks` call was made.  So this
# makes it a great way to hook into Rails and make changes.  If you were building a gem, and you wanted it to insert a middelware to your app
# you could listen to the `:after_initialize` hook, like so:

# in `demogem/lib/demogem.rb`
module DemoGem
  class Middleware
    def initialize(app); @app = app; end
    def call(env)
      puts env.inspect
      @app.call(env)
    end
  end

  if defined?(ActiveSupport)
    ActiveSupport.on_load(:after_initialize) do
      self.config.middleware.insert_before ActionDispatch::Static, DemoGem::Middelware
    end
  end
end

# running `rake middleware` before adding this:
#
# use ActionDispatch::Static
# ...
# run DemoApp::Application.routes
#
# Now we can hook into the after_initialize hook to load our middleware after our app
# is set up.  Inside the block `self` is the Rails Application object.
module DemoGem
  if defined?(ActiveSupport)
    ActiveSupport.on_load(:after_initialize) do
      self.config.middleware.insert_before ActionDispatch::Static, DemoGem::Middelware
    end
  end
end

# Now when we run `rake middleware` we will see our DemoGem::Middleware at the top of the stack:
#
# use DemoGem::Middleware
# use ActionDispatch::Static
# ...
# run DemoApp::Application.routes
#
# Rails ships with these hooks you can hook into to:
#
# :action_mailer
# :action_controller
# :action_view
# :active_record
# :before_configuration
# :before_initialize
# :before_eager_load
# :after_initialize

# http://www.simonecarletti.com/blog/2011/04/understanding-ruby-and-rails-lazy-load-hooks/
#
# You aren't limited to just the hooks Rails defines though, you can create your own.  Let's say
# you've built a Service class that is responsible for doing all your external http requests. 
# 
# When the Services class is finished initializing, you can run all the :service hooks:

class Services
  def self.add_service(service)
    # do some stuff here
  end

  ActiveSupport.run_load_hooks(:services, self)
end

# Then, in your service specific libraries, you can hook into this and add the specific service
# to the list of services:

class TwitterService
  ActiveSupport.on_load(:services) do
    self.add_service TwitterService
  end
end

class FlickrService
  ActiveSupport.on_load(:services) do
    self.add_service FlickrService
  end
end

# === Concern
#
# ActiveSupport::Concern makes it a little easier to create modules to be included in your classes, wrapping up
# a couple of common patterns into a nice DSL.
#
# The first one is modifying the class that is including the module.  This is how you would do it before (using our services example from the previous topic)

class Item < ActiveRecord::Base
  include Hideable
end

module Hideable
  def self.extended(klass)
    klass.extend ClassMethods
  end

  def ClassMethods
    def self.hidden
      where(hidden: true)
    end
  end

  def hide!
    update_attribute :hidden, true
  end
end

# This allows you to include a module and have it add class as well as instance methods.

# If you `extend` the `Hideable` module with `ActiveSupport::Concern`, it will automatically handle this for you:

module Hideable
  extend ActiveSupport::Concern

  def ClassMethods
    def self.hidden
      where(hidden: true)
    end
  end

  def hide!
    update_attribute :hidden, true
  end
end

# You can also have it call a block in the context of the Class including the module like so:

module Hideable
  extend ActiveSupport::Concern

  included do
    # modify the class here
    self.include_root_in_json = true
  end
end

# Advanced Concern.  If you every have modules that depend on each other, you know it can be a pain the butt. For example, maybe the
# Hideable module depends on a Modifiable. Without concern, you'd have to enforce the dependency on the class level:

class Item < ActiveRecord::Base
  include Modifiable
  include Hideable
end

# But you shouldn't have to know the details of Hideable's dependencies.  If another developer came in and "cleaned things up" by moving the `include Hideable`
# above the `include Modifiable`, stuff would break.
#
# Instead, you can extend both Modifiable and Hideable with ActiveSupport::Concern and then just do this:

module Modifiable
  extend ActiveSupport::Concern

  included do
    # some functionality that Hideable depends on
  end
  ...
end

module Hideable
  extend ActiveSupport::Concern

  include Modifiable
  ...
end

# Now the Item class just needs to include Hideable:
class Item < ActiveRecord::Base
  include Hideable
end


