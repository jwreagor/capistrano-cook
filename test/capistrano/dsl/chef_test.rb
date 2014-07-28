require 'minitest_helper'

class Capistrano::DSL::ChefTest < Minitest::Test

  include Capistrano::Chef::TestHelpers

  def test_chef_role
    user = "jimbo"
    hostname = "10.1.2.3"

    set :user, user
    stub_node :test_node_1 do |node|
      node.normal.ipaddress = hostname
    end

    chef_role :cachey, "name:test_node_1"

    servers_with_role :cachey do |server|
      assert_equal user,     server.user
      assert_equal hostname, server.hostname
    end
  end

  def test_chef_role_block
    user = "duder"
    hostname = "129.1.2.3"

    set :user, user
    stub_node :test_node_2 do |node|
      node.normal.ipaddress = "88.1.2.3"
      node.normal.network.interfaces.eth0.addresses[hostname].family = "inet"
    end

    chef_role :webbie, "name:test_node_2" do |node|
      node["network"]["interfaces"]["eth0"]["addresses"].map do |ipaddress, address|
        next ipaddress if address.family == "inet"
      end
    end

    servers_with_role :webbie do |server|
      assert_equal user,     server.user
      assert_equal hostname, server.hostname
    end
  end

  def test_chef_env
    env = "bumville"
    hostname = "84.9.1.11"

    stub_node :test_node_3 do |node|
      node.chef_environment = "box_spring"
      node.normal.ipaddress = "197.3.2.1"
    end

    stub_node :test_node_4 do |node|
      node.chef_environment = env
      node.normal.ipaddress = hostname
    end

    assert servers.to_a.size.zero?, "Should be no servers"

    chef_env env

    assert_includes fetch(:chef_scopes), "chef_environment:#{env}"

    chef_role :rubix, "name:test_node_*"

    assert_equal 1, servers.to_a.size

    servers_with_role :rubix do |server|
      assert_equal hostname, server.hostname
    end
  end

  def test_chef_scope
    env = "livefree"
    hostname = "197.3.2.1"

    stub_node :test_node_6 do |node|
      node.chef_environment = env
      node.normal.ipaddress = hostname
    end

    stub_node :test_node_5 do |node|
      node.chef_environment = "bumville"
      node.normal.ipaddress = "84.9.1.11"
    end

    assert servers.to_a.size.zero?, "Should be no servers"

    chef_scope :chef_environment, env

    assert_includes fetch(:chef_scopes), "chef_environment:#{env}"

    chef_role :rubix, "name:test_node_*"

    assert_equal 1, servers.to_a.size

    servers_with_role :rubix do |server|
      assert_equal hostname, server.hostname
    end
  end

end
