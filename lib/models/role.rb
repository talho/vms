require 'dispatcher'

module Vms
  Dispatcher.to_prepare do 
    ::Role.class_eval do
      def volunteers
        users.scoped
      end
    end
  end
end

