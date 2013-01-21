require 'rubygems'
require 'inline'

ENV['PATH'] = "c:\\MinGW\\bin;" + ENV['PATH'] unless ENV['PATH']["c:\\MinGW\\bin;"]

load 'introspective/object.rb'
load 'introspective/class.rb'
load 'introspective/i_class_analizer.rb'