require 'active_record'
require 'active_support/concern'

module HasDistance
  module Distance
    module Glue
      extend ActiveSupport::Concern

      module ClassMethods
        def has_distance(field_name=:distance, options={}, &block)
          cattr_accessor :distance_config
          self.distance_config = Struct.new(:column_name,
                                               :lat_name,
                                               :lng_name,
                                               :units,
                                               :distance,
                                               :limit
                                              ).new(
                                                field_name,
                                                options[:latitude] || 'latitude',
                                                options[:longitude] || 'longitude',
                                                options[:units] || :miles,
                                                options[:distance] || 20,
                                                options[:limit] || 12
                                              )

          if block_given?
            block.call(self.distance_config)
          end
        end
      end # ClassMethods

      module InstanceMethods
        KMS_PER_MILE = 1.609
        NMS_PER_MILE = 0.868976242
        EARTH_RADIUS_IN_MILES = 3963.19
        EARTH_RADIUS_IN_KMS = EARTH_RADIUS_IN_MILES * KMS_PER_MILE
        EARTH_RADIUS_IN_NMS = EARTH_RADIUS_IN_MILES * NMS_PER_MILE

        def nearby(options={})
          _config = self.distance_config

          _local_latitude   = self.send(_config.lat_name)
          _local_longitude  = self.send(_config.lng_name)
          _distance_name    = _config.column_name

          _distance = options.delete(:distance)
          _distance = _distance ? _distance : _config.distance
          _limit = options.delete(:limit) || _config.limit

          _lat = _deg2rad(_local_latitude)
          _lng = _deg2rad(_local_longitude)

          _sql = _sphere_distance_sql(_lat, _lng, _units_sphere_multiplier(_config.units))
          _sql << " AS #{_config.column_name}"

          _klass = self.class
          _arreflector = _klass.select("*, #{_sql}").group('id').
            having("#{_distance_name} <= #{_distance}")

          if !_limit.nil?
            _arreflector.limit(_limit)
          else
            _arreflector
          end
        end

        private
        def _qualified_lat_column_name
          self.distance_config.lat_name
        end

        def _qualified_lng_column_name
          self.distance_config.lng_name
        end

        def _create_db_functions(db)
           db.create_function("COS", 1) do |func, value|
             func.result = Math.cos(value)
           end

           db.create_function("SIN", 1) do |func, value|
             func.result = Math.sin(value)
           end

           db.create_function('ACOS', 1) do |func, value|
             func.result = Math.acos(value)
           end

           db.create_function('RADIANS', 1) do |func, value|
             func.result = _deg2rad(value)
           end

           db.create_function('least', 2) do |func, v1, v2|
             func.result = [v1, v2].min
           end
        end

        def _sphere_distance_sql(lat, lng, multiplier)
           db = self.class.connection.instance_variable_get(:@connection)
           _create_db_functions(db) if db.class.to_s =~ /SQLite3/i

           # Took this part from Geokit
          %|
            (ACOS(least(1,COS(#{lat})*COS(#{lng})*COS(RADIANS(#{_qualified_lat_column_name}))*COS(RADIANS(#{_qualified_lng_column_name}))+
            COS(#{lat})*SIN(#{lng})*COS(RADIANS(#{_qualified_lat_column_name}))*SIN(RADIANS(#{_qualified_lng_column_name}))+
            SIN(#{lat})*SIN(RADIANS(#{_qualified_lat_column_name}))))*#{multiplier})
           |
        end

        def _units_sphere_multiplier(units)
          case units
          when :kms; EARTH_RADIUS_IN_KMS
          when :nms; EARTH_RADIUS_IN_NMS
          else EARTH_RADIUS_IN_MILES
          end
        end

        def _deg2rad(degrees)
         degrees.to_f / 180.0 * Math::PI
        end
      end # InstanceMethods

    end # Glue
  end # Distance
end
