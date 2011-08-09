require 'has_distance'
require 'rails'

module HasDistance
  class Railtie < ::Rails::Railtie

    initializer 'has_distance.insert_into_active_record' do
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.send(:include, HasDistance::Distance::Glue)
      end
    end

  end
end
