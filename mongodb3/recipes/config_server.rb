#Sets up the config server for the sharded mongodb cluster

mongodb_instance 'mongodb' do
  mongodb_type 'mongod'
  repl_name    node['mongodb3']['configsvr']['replica_set_name']
  configsvr    true
  port         node['mongodb3']['configsvr']['port']
  cluster_name node['mongodb3']['cluster_name']
end
