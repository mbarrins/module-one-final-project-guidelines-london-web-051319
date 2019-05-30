require 'bundler'
require 'JSON'
Bundler.require

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
ActiveRecord::Base.logger = nil
require_all 'lib'
require_all 'app'

APIKEY = "sqj3GomEiDTyMWkLzNhfrH0r62ZC82EA"
EVENTSURL = "https://app.ticketmaster.com/discovery/v2/events?"
CLASSURL = "https://app.ticketmaster.com/discovery/v2/classifications?"
