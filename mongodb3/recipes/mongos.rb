#
# Cookbook Name:: mongodb3
# Recipe:: default
#
<<<<<<< HEAD
# Copyright 2015, UrbanLadder
=======
# Copyright 2015, Sunggun Yu
>>>>>>> 59123b7291922651a404c2a0fef43fc9bb9029c0
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'mongodb3::package_repo'

# Install Mongos package
install_package = %w(mongodb-org-shell mongodb-org-mongos mongodb-org-tools)

<<<<<<< HEAD
# Setup package version to install
case node['platform_family']
  when 'rhel', 'fedora'
    package_version = "#{node['mongodb3']['version']}-1.el#{node.platform_version.to_i}" # ~FC019
  when 'debian'
    package_version = node['mongodb3']['version']
end

install_package.each do |pkg|
  package pkg do
    version package_version
    options "--force-yes"
=======
install_package.each do |pkg|
  package pkg do
    version node['mongodb3']['package']['version']
>>>>>>> 59123b7291922651a404c2a0fef43fc9bb9029c0
    action :install
  end
end

# Mongos configuration
# Create the mongodb user if not exist
user node['mongodb3']['user'] do
  action :create
end

<<<<<<< HEAD
members = get_members(:node, "name:#{node['mongodb3']['discovery']['query']}", node)

members.map! do |member|
  "#{member}:#{node['mongodb3']['configsvr']['port'].to_s}"
end

node.set['mongodb3']['config']['mongos']['sharding']['configDB'] = "#{node['mongodb3']['configsvr']['replica_set_name']}/#{members.join(',')}"

=======
>>>>>>> 59123b7291922651a404c2a0fef43fc9bb9029c0
# Create the Mongos config file
template node['mongodb3']['mongos']['config_file'] do
  source 'mongodb.conf.erb'
  owner node['mongodb3']['user']
  mode 0644
  variables(
      :config => node['mongodb3']['config']['mongos']
  )
  helpers Mongodb3Helper
<<<<<<< HEAD
=======
  notifies :restart, 'runit_service[mongos]'
>>>>>>> 59123b7291922651a404c2a0fef43fc9bb9029c0
end

# Create the log directory
directory File.dirname(node['mongodb3']['config']['mongos']['systemLog']['path']).to_s do
  owner node['mongodb3']['user']
  action :create
  recursive true
end

# Install runit service package
# packagecloud cookbook is not working for oracle linux.
if node['platform'] == 'oracle'
  # Install pygpgme package for imeyer runit yum repository
  package 'pygpgme' do
    ignore_failure true
  end
  # Install imeyer runit packagecloud yum repository
  yum_repository 'imeyer_runit' do
    description 'imeyer_runit'
    baseurl 'https://packagecloud.io/imeyer/runit/el/6/$basearch'
    gpgkey 'https://packagecloud.io/gpg.key'
    sslcacert '/etc/pki/tls/certs/ca-bundle.crt'
    sslverify false
    gpgcheck false
    action :create
  end
  # Set `['runit']['prefer_local_yum'] = true` to avoid install yum repository through packagecloud cookbook
  node.set['runit']['prefer_local_yum'] = true
end

# Install runit service package through runit::default recipe
include_recipe 'runit::default'

# Adding `mongos` service with runit
runit_service 'mongos' do
  retries 3
  restart_on_update true
<<<<<<< HEAD
=======
  cookbook node['mongodb3']['mongos']['runit_template_cookbook']
>>>>>>> 59123b7291922651a404c2a0fef43fc9bb9029c0
  options ({
              :user => node['mongodb3']['user'],
              :config_file => node['mongodb3']['mongos']['config_file']
          })
end
