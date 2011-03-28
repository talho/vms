require 'dispatcher'

module Vms
  Dispatcher.to_prepare do 
    ::User.class_eval do
      has_many :scenarios, :class_name => 'Vms::Scenario', :foreign_key => 'creator_id'
      acts_as_taggable_on :qualifications
    end
  end
end

