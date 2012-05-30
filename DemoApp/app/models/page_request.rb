class PageRequest < ActiveRecord::Base
  attr_accessible :duration, :end_time, :start_time

  def to_s
    "(#{self.status}) #{self.http_method} '#{self.path}' to #{self.controller_name}##{self.action_name}"
  end
end
