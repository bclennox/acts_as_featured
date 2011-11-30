require 'active_record'
  
require File.dirname(__FILE__) + '/../init'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => File.dirname(__FILE__) + '/test.sqlite3')

require File.dirname(__FILE__) + '/models.rb'
