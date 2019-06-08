node['mongodb']['ruby_gems'].each do |gem, version|
  chef_gem gem do
    version version
  end
end
