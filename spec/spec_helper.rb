$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'has_distance'
require 'sqlite3'
require 'csv-mapper'

CURRENT_PATH = File.dirname(__FILE__)
# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{CURRENT_PATH}/support/**/*.rb"].each {|f| require f}

class Store < ActiveRecord::Base
  include HasDistance::Distance::Glue
end

RSpec.configure do |config|
end

ActiveRecord::Base.establish_connection({
  :adapter   => 'sqlite3',
  :database  => "#{CURRENT_PATH}/support/test.db"
})

ActiveRecord::Schema.define do
  create_table :stores, :force => true do |t|
    t.string :name, :unique => true
    t.string :city
    t.string :state
    t.text :description
    t.decimal :latitude, :precision => 15, :scale => 12
    t.decimal :longitude, :precision => 15, :scale => 12
    t.timestamps
  end
end

include CsvMapper

results = import("#{CURRENT_PATH}/support/stores.csv") do
  read_attributes_from_file
end

results.each do |res|
  person = Store.new
  person.name        = res.name
  person.city        = res.city
  person.state       = res.state
  person.description = res.description
  person.latitude    = res.latitude
  person.longitude   = res.longitude
  person.save
end
sleep 5
