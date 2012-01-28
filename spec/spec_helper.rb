require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => File.join(File.dirname(__FILE__), 'test.sqlite3'))

require File.join(File.dirname(__FILE__), 'models')
