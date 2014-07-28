require 'chef/knife'
require_relative 'dsl/chef'
require_relative 'chef/version'

knife = Chef::Knife.new
# If you don't do this it gets thrown into debug mode
knife.configure_chef

self.extend Capistrano::DSL::Chef
