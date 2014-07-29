require "sshkit"
require "capistrano/configuration"
require "chef_zero/server"

module Capistrano
  module Chef
    # @api private
    module TestHelpers

      include Capistrano::DSL::Chef

      extend Forwardable

      def_delegators ::Capistrano::Configuration, :env, :reset!

      def setup
        if chef_server.running?
          chef_server.stop
        end

        chef_server.start_background
        super
      end

      def teardown
        reset!
        chef_server.stop if chef_server.running?
        super
      end

      def chef_server
        @chef_server ||= ::ChefZero::Server.new \
          port: 8889,
          debug: !!ENV['DEBUG'],
          single_org: false
      end

      def servers
        env.send(:servers)
      end

      def servers_with_role(role)
        servers.map do |server|
          next unless server.properties.roles.include?(role)
          yield server if block_given?
          server
        end
      end

      def nodes
        @nodes ||= {}
      end

      def stub_node(name, &block)
        name = name.to_s || "test_node_#{nodes.keys.size}"
        nodes[name] = ::Chef::Node.build(name).tap(&block)
        data = ::JSON.fast_generate(nodes[name])
        chef_server.load_data({ "nodes" => { name => data }})
        nodes[name]
      end

      def method_missing(name, *args)
        if env.respond_to?(name)
          env.__send__(name, *args)
        else
          super name, *args
        end
      end

    end
  end
end
