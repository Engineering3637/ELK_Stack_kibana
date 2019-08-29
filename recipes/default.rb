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

apt_repository 'logstash' do
  uri 'http://packages.elastic.co/logstash/2.2/debian stable main'
  trusted false
  components ['logstash']
end

package 'elasticsearch'

template '/etc/elasticsearch/elasticsearch.yml' do
  source 'elasticsearch.yml.erb'
end


service 'elasticsearch' do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end

execute 'Start on boot' do
  command 'sudo update-rc.d elasticsearch defaults 95 10'
end

package 'kibana'

template '/etc/kibana/kibana.yml' do
  source 'kibana.yml.erb'
end

execute 'Setup kibana' do
  command "sudo update-rc.d kibana defaults 96 9"
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
# name = 'server'
#
# logstash_instance name do
#   action :create
# end
#
# logstash_service name do
#   action [:enable]
# end
#
# logstash_config name do
#   action [:create]
#   notifies :restart, "logstash_service[#{name}]"
# end
#
# logstash_plugins 'contrib' do
#   instance name
#   name 'logstash-output-influxdb'
#   action [:create]
# end
#
# logstash_pattern name do
#   action [:create]
# end
#
# logstash_curator 'server' do
#   action [:create]
# end

package "nginx"

package "apache2-utils"

execute 'Setup the credentials' do
  command 'sudo htpasswd -c /etc/nginx/htpasswd.users devops3637'
  command 'password'
end

template '/etc/nginx/sites-available/default' do
  source 'default.erb'
  variables server_name: node['nginx']['server_name']
  notifies :restart, 'service[nginx]'
end


package 'logstash'

directory '/etc/pki/' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory '/etc/pki/tls/' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory '/etc/pki/tls/certs' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory '/etc/pki/tls/private' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

template '/etc/ssl/openssl.cnf' do
  source 'openssl.cnf.erb'
  variables server_name: node['ssl']['ServerPrivateIP']
  notifies :restart, 'service[ssl]'
end

execute 'generate ssl certificate' do
  command 'cd /etc/pki/tls'
  command 'sudo openssl req -config /etc/ssl/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt'
end

template '/etc/logstash/conf.d/02-beats-input.conf' do
  source '02-beats-input.conf'
end

template '/etc/logstash/conf.d/10-syslog-filter.conf' do
  source '10-syslog-filter.conf'
end

template '/etc/logstash/conf.d/30-elasticsearch-output.conf' do
  source '30-elasticsearch-output.conf'
  notifies :restart, 'service[logstash]'
end

execute 'setup logstash and load dashboards' do
  command 'sudo update-rc.d logstash defaults 96 9'
  command 'cd ~'
  command 'curl -L -O https://download.elastic.co/beats/dashboards/beats-dashboards-1.1.0.zip'
  command 'sudo apt-get -y install unzip'
  command 'unzip beats-dashboards-*.zip'
  command 'cd beats-dashboards-*'
  command './load.sh'
  command 'cd ~'
  command 'curl -O https://gist.githubusercontent.com/thisismitch/3429023e8438cc25b86c/raw/d8c479e2a1adcea8b1fe86570e42abab0f10f364/filebeat-index-template.json'
  command "curl -XPUT 'http://localhost:9200/_template/filebeat?pretty' -d@filebeat-index-template.json"

end
