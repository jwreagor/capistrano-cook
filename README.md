# capistrano-cook

[![Build Status](https://travis-ci.org/cheapRoc/capistrano-cook.svg?branch=master)](https://travis-ci.org/cheapRoc/capistrano-cook) [![Dependency Status](https://gemnasium.com/cheapRoc/capistrano-cook.svg)](https://gemnasium.com/cheapRoc/capistrano-cook) [![Gem Version](https://badge.fury.io/rb/capistrano-cook.svg)](http://badge.fury.io/rb/capistrano-cook)

_capistrano-cook_ is a fork of [Capistrano::Chef][fork].

The goal of _capistrano-cook_ is to provide a set of tools you may or may not
need when you'd like to use [Capistrano][cap] and [Chef][chef] together.

**Note**: capistrano-cook will not support older versions of Capistrano prior to
version 3.

## Install

    $ echo "gem 'capistrano-cook'" >> Gemfile
    $ bundle install
    $ echo "require 'capistrano/chef'" >> Capfile

It doesn't matter if you require `"capistrano/chef"` or `"capistrano/cook"`.

## Knife Configuration

A Chef Server configuration is expected to be available as [Knife][knife] is
used to configure this library. You must have a `.chef` directory including a
configured `knife.rb` in either the current directory or one it's parents. After
running `bundle install` check to see if you can use the `knife` command
properly.

If you're using [Hosted Chef][hosted] these configuration files will be provided
to you.

If not, the configuration can be generated with `knife configure -i`.

See the [Chef Documentation][config] for more details.

**TIP**: Symlink it in from another project.

## Roles

Capistrano allows you to specify the roles of your application and which
specific server hosts are members of those roles.

Chef also has its own unique concept of roles. A role in Chef can be assigned to
any node and provide that node with with special attributes or cookbooks.

__capistrano-cook__ provides a number of helper methods that allow you to utilize
Chef roles and their data from within Capistrano.

### Examples

A normal `deploy.rb` in an app using capistrano defines roles like this:

```ruby
    role :web, '10.0.0.2', '10.0.0.3'
    role :db, '10.0.0.2', :primary => true
```

Using `capistrano-cook`, you can do this:

```ruby
    require 'capistrano/chef'

    chef_role :web 'role:web'
    chef_role :db, 'role:database AND tag:master', primary: true,
                                                   attribute: :private_ip,
                                                   limit: 1
```

Use a Hash to get a specific network interface.

The Hash must be in the form of `{ 'interface-name' => 'network-family-name' }`.

```ruby
    chef_role :web, 'role:web', attribute: { eth1: :inet }
```

For a more deep and complex attribute search, call with a block.

```ruby
    chef_role :web, 'roles:web' do |node|
      node["network"]["interfaces"]["eth1"]["addresses"].select do |address, data|
        data["family"] == "inet"
      end.keys.first
    end
```

This defines the same roles using [Chef's search feature][search]. Nodes are
searched using the given query. The node's `ipaddress` attribute is used by
default, but other attributes can be specified in the options as shown in the
examples above. The rest of the options are the same as those used by
Capistrano.

You can also define multiple roles at the same time if the host list is
identical. Instead of running multiple searches to the Chef server, you can pass
an Array to `chef_role`:

```ruby
    chef_role [:web, :app], 'role:web'
```

## Search

You can also perform generic searches against your Chef Server search indexes.

### Examples

Calling `chef_search` will result in an enumerable of Chef::Node objects.

```ruby
    nodes = chef_search :node, "name:backup_database"
    nodes.each { |node| puts node.name }
```

You can also scope your search calls so that you don't need to constantly
include the same search terms for each `chef_role` or `chef_search` call.

This next example will return all nodes which are tagged with "migrations"
within the "myface_production" Chef environment.

```ruby
    chef_scope "chef_environment:myface_production"

    chef_search :node, "tag:migrations"
```

There is also a short hand version for defining your environment name. The
following performs the same as the above `chef_scope` call.

```ruby
    chef_env "myface_production"
```

## Contributing

* Fork the project.
* Make your feature addition or bug fix in a topic branch.
* Add tests for it. This is important so I don't break it in a future version
  unintentionally.
* Commit, do not mess with Rakefile or version (if you want to have your own
  version, that is fine but bump version in a commit by itself I can ignore when
  I pull)
* Update (rebase) your commits with my master.
* Send me a pull request.

## License

See [LICENSE](license).

[chef]: http://www.getchef.com/
[cap]: http://capistranorb.com/
[old]: http://rubygems.org/gems/capistrano-chef/versions/0.1.0
[fork]: http://github.com/gofullstack/capistrano-chef
[search]: http://wiki.opscode.com/display/chef/Search
[knife]: http://wiki.opscode.com/display/chef/Knife
[config]: http://wiki.opscode.com/display/chef/Chef+Repository#ChefRepository-Configuration
[hosted]: http://www.opscode.com/hosted-chef/
[license]: http://github.com/cheapRoc/capistrano-cook/blob/master/LICENSE
