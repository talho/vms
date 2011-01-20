require 'dispatcher'

module Vms
  module User
    def self.included(base)
      base.has_many :scenarios, :class_name => 'Vms::Scenario', :foreign_key => 'creator_id'
    end
  end
  Dispatcher.to_prepare do
    ::User.send(:include, Vms::User)
  end
end

