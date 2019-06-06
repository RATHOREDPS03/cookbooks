define :mongodb_instance,
:mongodb_type  => 'mongod',
:repl_name     => 'mongo1',
:configsvr     => false,
:port          => 9000,
:cluster_name  => "mongodb",
:shards        => 1 do

  require 'bson'

  node_count = 0
  params[:shards].times do

    config = {}
    ruby_block "replica_set" do
      block do
        hosts = fetch_databag()

        begin
          config = replset_config(node_count, node, params)
          validate_instance(config)

          dir = Chef::Resource::Directory.new(node['mongodb3']['mongod']['log_dir'], run_context)
          dir.recursive(true)
          dir.owner(node['mongodb3']['user'])
          dir.group(node['mongodb3']['user'])
          dir.run_action(:create)

          dir = Chef::Resource::Directory.new(node['mongodb3']['config']['mongod']['storage']['dbPath'], run_context)
          dir.recursive(true)
          dir.owner(node['mongodb3']['user'])
          dir.group(node['mongodb3']['user'])
          dir.run_action(:create)

          template = Chef::Resource::Template.new(node['mongodb3']['mongod']['config_file'], run_context)
          template.source 'mongodb.conf.erb'
          template.mode '0644'
          template.owner node['mongodb3']['user']
          template.group node['mongodb3']['user']
          template.cookbook "mongodb3"
          template.variables(
          :config => node['mongodb3']['config']['mongod']
          )
          template.helpers Mongodb3Helper
          template.run_action :create

          template = Chef::Resource::Template.new(config['upstart_conf'], run_context)
          template.source 'mongod.upstart.erb'
          template.mode '0644'
          template.owner node['mongodb3']['user']
          template.group node['mongodb3']['user']
          template.cookbook "mongodb3"
          template.variables(
          :config_file => node['mongodb3']['mongod']['config_file'],
          :instance_name => "mongod",
          :pid_file => node['mongodb3']['pid_file']
          )
          template.helpers Mongodb3Helper
          template.run_action :create

          service = Chef::Resource::Service.new(config['instance_name'], run_context)
          service.supports :start => true, :stop => true, :restart => true, :status => true
          service.provider Chef::Provider::Service::Upstart
          service.run_action :start

          Mongodb.config_replicaset(config, node)

          databag = {'replsetname' => node['mongodb3']['config']['mongod']['replication']['replSetName'], 'port' => node['mongodb3']['config']['mongod']['net']['port']}
          write_to_data_bag(databag)
          node_count += 1
        rescue RuntimeError
          Chef::Log.warn("The replica sets are created for the given shard count.")
        end
      end
    end
  end
end
