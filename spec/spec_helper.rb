require 'spec'
require 'rubygems'
require 'active_record'
  
$: << File.join(File.dirname(__FILE__), '../lib')

require File.dirname(__FILE__) + '/../init'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => File.dirname(__FILE__) + '/test.sqlite3')

require File.dirname(__FILE__) + '/models.rb'
