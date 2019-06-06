require 'json'

class Chef::Mongodb

  def self.config_replicaset(params, node)

    require 'rubygems'
    require 'bson'
    require 'mongo'

    members = get_members(:node, "name:#{node['mongodb3']['discovery']['query']}", node)
    cluster_hosts = []
    members.each_with_index do |member, index|
      cluster_hosts << {'_id' => index, 'host' => "#{member}:#{params['port']}"}
    end

    cmd = BSON::OrderedHash.new
    cmd['replSetInitiate'] = {
      '_id' => params['repl_name'],
      'members' => cluster_hosts
    }

    cmd['replSetInitiate']['configsvr'] = true if params['configsvr']

    begin
      connection = nil
      rescue_connection_failure do
        connection = Mongo::Connection.new("localhost", params['port'].to_s, :op_timeout => 5, :slave_ok => true)
        connection.database_names # check connection
      end
    rescue => e
      Chef::Log.warn("Could not connect to database: 'localhost:#{params['port'].to_s}', reason: #{e}")
    end

    Chef::Log.warn(params)
    begin
      admin = connection['admin']
      result = admin.command(cmd, :check_response => false)
    rescue Mongo::OperationTimeout
      Chef::Log.info('Started configuring the replicaset, this will take some time, another run should run smoothly')
    end

    Chef::Log.warn(result)
    if result.fetch('ok', nil) == 1
      Chef::Log.warn("Replica set initiated")
    elsif result.fetch('errmsg', nil) =~ /(\S+) is already initiated/ || (result.fetch('errmsg', nil) == 'already initialized')
      begin
        connection = Mongo::Connection.new("localhost", params['port'].to_s, :op_timeout => 5, :slave_ok => true)
      rescue
        abort("Could not connect to database: 'localhost:#{params['port']}'")
      end

      config = connection['local']['system']['replset'].find_one('_id' => params['repl_name'])
      old_members = config['members'].map { |m| m['host'] }
      old_config = config['members'].map { |member| { '_id'=> member['_id'], 'host' =>member['host']} }
      missing_hosts = cluster_hosts - old_config
      missing_hosts.each_with_index do |host, index|
        host['_id'] = config['members'].count + index
        config['members'] << host
      end

      config['version'] += 1
      rs_conn = nil
      rescue_connection_failure do
        rs_conn = Mongo::ReplSetConnection.new(old_members, :name => params['repl_name'], :read_secondary => true)
        rs_conn.database_names # check connection
      end

      admin = rs_conn['admin']

      cmd = BSON::OrderedHash.new
      cmd['replSetReconfig'] = config
      begin
        result = admin.command(cmd, :check_response => true)
      rescue Mongo::OperationTimeout,  Mongo::OperationFailure
        Chef::Log.warn("ReplicaSet is already initialized.")
      end

      if result.fetch('ok', nil) == 1
        Chef::Log.warn("Replica set initiated")
      else
        Chef::Log.warn(result)
      end
    end
  end

  def self.rescue_connection_failure(max_retries = 30)
    retries = 0
    begin
      yield
    rescue Mongo::ConnectionFailure => ex
      retries += 1
      raise ex if retries > max_retries
      sleep(0.5)
      retry
    end
  end
end

def get_members(index, query, node)

  chef_search = Chef::Search::Query.new
  cluster_nodes = chef_search.search(index, query)
  members = cluster_nodes[0] if cluster_nodes
  nodes = []

  Chef::Log.warn(members.to_json)
  if cluster_nodes && cluster_nodes.size > 0
    members.each do |member|
      nodes.push(member['private_ip']) if node['opsworks']['stack']['id'] == member[:opsworks][:stack][:id]
    end
  else
    nodes = []
  end

  return nodes
end

def write_to_data_bag(data)
  begin
    config = data_bag_item(node['mongodb3']['cluster_name'], node['mongodb3']['cluster_name'])
    config['hosts'] << data
    config.save
  rescue Net::HTTPServerException
    Chef::Log.warn("Databag #{node['mongodb3']['cluster_name']} node found. Creating a new one.")
    databag = Chef::DataBagItem.new
    databag.data_bag(node['mongodb3']['cluster_name'])
    databag.raw_data = {"id" => node['mongodb3']['cluster_name'], "hosts" => [data]}
    databag.save
  end
end

def fetch_databag()
  begin
    config = data_bag_item(node['mongodb3']['cluster_name'], node['mongodb3']['cluster_name'])
  rescue Net::HTTPServerException
    return {'id' => node['mongodb3']['cluster_name'], 'hosts' => [] }
  end
end

def replset_config(hosts, node, params)
  config = {}
  instance_name = 'mongod' + (hosts + 1).to_s
  if params[:configsvr]
    node.set['mongodb3']['config']['mongod']['sharding']['clusterRole'] = "configsvr"
    instance_name = "configsvr"
  end
  node.set['mongodb3']['config']['mongod']['net']['port'] = params[:port] + hosts
  node.set['mongodb3']['config']['mongod']['replication']['replSetName'] = params[:repl_name]+ (hosts + 1).to_s
  node.set['mongodb3']['pid_file']= "/var/run/#{instance_name}.pid"
  node.set['mongodb3']['mongod']['config_file'] = "/etc/#{instance_name}.conf"
  node.set['mongodb3']['mongod']['log_dir'] = "#{node['mongodb3']['log_dir']}/#{instance_name}"
  node.set['mongodb3']['config']['mongod']['systemLog']['path'] = "#{node['mongodb3']['log_dir']}/#{instance_name}/mongod.log"
  node.set['mongodb3']['config']['mongod']['storage']['dbPath'] = "#{node['mongodb3']['dbPath']}/#{instance_name}"
  config['instance_name'] = instance_name
  config['upstart_conf'] = "/etc/init/#{instance_name}.conf"
  config['port'] = node['mongodb3']['config']['mongod']['net']['port']
  config['repl_name'] = node['mongodb3']['config']['mongod']['replication']['replSetName']
  config['configsvr'] = params[:configsvr]
  config
end

def validate_instance(config)
  stored_config = fetch_databag()
  stored_config['hosts'].each do |value|
    raise "The replica sets are already configured." if value['replsetname'] == config['repl_name']
  end
end
