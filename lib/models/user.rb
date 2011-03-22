require 'dispatcher'

module Vms
  Dispatcher.to_prepare do 
    ::User.instance_eval do
      has_many :scenarios, :class_name => 'Vms::Scenario', :foreign_key => 'creator_id'
    end
  end
end

