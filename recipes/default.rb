#
# Cookbook:: kibana
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.
apt_repository 'elasticsearch' do
  uri 'http://packages.elastic.co/elasticsearch/2.x/debian stable main" '
  key 'https://packages.elastic.co/GPG-KEY-elasticsearch'
  trusted false
  components ['elasticsearch']
end

apt_repository 'kibana' do
  uri 'http://packages.elastic.co/kibana/4.5/debian stable main'
  trusted false
  components ['kibana']
end

apt_update 'update_sources' do
  action :update
end

package 'elasticsearch'

template '/etc/elasticsearch/elasticsearch.yml' do
  source 'elasticsearch.yml.erb'
end


service 'elasticsearch' do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end

package 'kibana'
service 'kibana' do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end

execute 'Start on boot' do
  command 'sudo update-rc.d elasticsearch defaults 95 10'
end
