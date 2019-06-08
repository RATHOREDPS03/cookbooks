include_recipe 'mongodb3::package_repo'

# Install MongoDB package
install_package = %w(mongodb-org-server mongodb-org-shell mongodb-org-tools)

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
    options '--force-yes'
    action :install
  end
end
