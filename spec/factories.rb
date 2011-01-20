require 'factory_girl'

Factory.define :scenario, :class => Vms::Scenario do |m|
  m.name "Scenario"
  m.association :creator, :factory => :user
  m.state Vms::Scenario::STATES[:unexecuted]
end
