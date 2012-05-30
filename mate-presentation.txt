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
# <%= @item.name if @item.present? %>
#
# === Wrap up of Core Ext
#
# Where can you find these core extensions? In the source: (include directory structure)
