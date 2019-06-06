template '/etc/logrotate.d/mongodb' do
  path '/etc/logrotate.d/mongodb'
  backup false
  source 'logrotate.erb'
  owner 'root'
  group 'root'
  mode 0644
end
