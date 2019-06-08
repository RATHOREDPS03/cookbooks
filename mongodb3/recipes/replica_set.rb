include_recipe 'mongodb3::install'
include_recipe 'mongodb3::mongo_gem'

#This is to stop the default mongod process that starts running after installation.
service 'mongod' do
  provider Chef::Provider::Service::Upstart
  action :stop
end

mongodb_instance 'mongodb' do
  mongodb_type 'mongod'
  repl_name    node['mongodb3']['config']['mongod']['replication']['replSetName']
  configsvr    false
  port         node['mongodb3']['config']['mongod']['net']['port']
  cluster_name node['mongodb3']['cluster_name']
  shards       node['mongodb3'][node['mongodb3']['cluster_name']]['number_of_shards']
end
