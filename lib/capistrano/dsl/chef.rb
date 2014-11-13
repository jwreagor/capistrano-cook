require 'chef/search/query'
require 'capistrano/chef/helpers'

module Capistrano
  module DSL
    # @api private
    module Chef
      #
      # @attr_writer chef_query_class [Chef::Search::Query, #new<#search>] the dependency class we query for Chef data
      #
      # @attr_writer chef_context [Capistrano::Configuration] the Capistrano.env object we configure
      #
      # @api public
      #

      #
      # Includes some private library helpers
      #
      include Capistrano::Chef::Helpers

      #
      # Provide a way to customize the interface methods our internals use at
      # runtime.
      #
      def self.included(klass)
        klass.send :attr_writer, :chef_query_class
        klass.send :attr_writer, :chef_context
      end

      #
      # Set a default Chef environment name for our #chef_search calls.
      #
      # @param env [Symbol, String] name of the Chef environment to search
      #
      # @api public
      #
      def chef_env(env)
        chef_scope :chef_environment, env
      end

      #
      # Set a term that is included for every #chef_search call.
      #
      # @param field [Symbol, String] field to search
      # @param term [String] query term to search
      #
      # @api public
      #
      def chef_scope(field, term="*")
        scopes = fetch(:chef_scopes) || []
$        scopes.delete_if { |scope| scope =~ /chef_environment/ }
        set :chef_scopes, scopes << [field, term].join(":")
      end

      #
      # Set a Capistrano roles by searching a Chef Server for appropriate node
      # data
      #
      # @param name [String, Symbol, Array<String, Symbol>] roles to set
      # @param query [String] query for searching a chef server
      # @param options [Hash] optional role and search criteria
      # @param block [Proc] block used to filter search result nodes
      # @return [Array<Hash>] map of hashes of user and host pairs by role name
      #
      # @api public
      #
      def chef_role(names, query=nil, options={}, &block)
        user = options[:user] ||= fetch(:user)
        attribute = options.delete(:attribute) || :ipaddress
        index = options.delete(:index) || :node
        results_proc = block_given? ? block : chef_results_by(attribute)
        terms = [index, query].compact
        addresses = chef_search(*terms).flat_map(&results_proc)

        addresses.each do |address|
          server address, options.merge(roles: names)
        end
      end

      #
      # Query a Chef Server to search for specific nodes
      #
      # @param type [Symbol] type of chef objects to query
      # @param query [String] query string
      # @return [Array<Chef::Node>] list of node results found
      #
      # @api public
      #
      def chef_search(type, query="*:*")
        chef_scopes = fetch(:chef_scopes) || []
        queries = [chef_scopes, query].flatten.join(" AND ")
        puts "Searching Chef types \"#{type}\" with \"#{queries}\"" if debug?
        results = chef_query_class.new.search(type, queries).first
        puts "Found #{results.count}" if debug?
        results
      end

      private

      #
      # Interface dependency using Chef for searching by default
      #
      def chef_query_class
        @chef_query_class ||= ::Chef::Search::Query
      end

      #
      # Interface dependency of our Capistrano config context
      #
      def chef_context
        @chef_context || ::Capistrano.env
      end

      #
      # Query a Chef Server to search for specific nodes
      #
      def chef_results_by(attribute)
        case attribute
        when Symbol, String
          lambda { |node| node[attribute] }
        when Hash # not tested
          iface, family = attribute.keys.first.to_s, attribute.values.first.to_s
          lambda do |nodes|
            addresses = node["network"]["interfaces"][iface]["addresses"]
            addresses.select do |address, data|
              data["family"] == family
            end.to_a.first.first
          end
        else
          Proc.new {} # noop
        end
      end
    end
  end
end

