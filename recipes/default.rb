#
# Cookbook:: kibana
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

apt_update 'update_sources' do
  action :update
end

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

package 'elasticsearch'

template '/etc/elasticsearch/elasticsearch.yml' do
  source 'elasticsearch.yml.erb'
end


service 'elasticsearch' do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end

package 'kibana'

template '/etc/kibana/kibana.yml' do
  source 'kibana.yml.erb'
end

service 'kibana' do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end

apt_update 'update_sources' do
  action :update
end

#
# package 'logstash' do
#   # options '--allow-unauthenticated'
#   action :install
# end
#
# service 'logstash' do
#   action [:enable, :start]
# end
# install logstash 'server'
name = 'server'

logstash_instance name do
  action :create
end

logstash_service name do
  action [:enable]
end

logstash_config name do
  action [:create]
  notifies :restart, "logstash_service[#{name}]"
end

logstash_plugins 'contrib' do
  instance name
  name 'logstash-output-influxdb'
  action [:create]
end

logstash_pattern name do
  action [:create]
end

logstash_curator 'server' do
  action [:create]
end


execute 'Start on boot' do
  command 'sudo update-rc.d elasticsearch defaults 95 10'
end
