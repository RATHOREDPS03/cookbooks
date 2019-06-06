apt_repository 'mongodb-org-3.2' do
  uri 'http://repo.mongodb.org/apt/debian'
  components ['main']
  key 'D68FA50FEA312927'
  distribution "wheezy/mongodb-org/3.2"
  keyserver 'keyserver.ubuntu.com'
end

apt_package 'mongodb-org-tools' do
  action :install
end
