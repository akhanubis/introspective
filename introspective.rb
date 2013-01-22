require 'rubygems'
require 'bundler'
Bundler.require

ENV['PATH'] = "c:\\MinGW\\bin;" + ENV['PATH'] unless ENV['PATH']["c:\\MinGW\\bin;"]

load 'introspective/common.rb'
load 'introspective/method_locator.rb'
load 'introspective/object.rb'
load 'introspective/class.rb'
load 'introspective/module.rb'
load 'introspective/i_class_analizer.rb'