#
# Cookbook:: kibana
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

execute 'Java and Elasticsearch install ' do
  command "apt-get update"
  command "sudo apt install default-jre"
#
# execute 'test' do
#   command "sudo apt install default-jdk"
# end
  command "wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -"
  command "echo 'deb http://packages.elastic.co/elasticsearch/2.x/debian stable main' | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list"
  command "apt-get update"
  command "sudo apt-get install elasticsearch -y"
end

template '/etc/elasticsearch/elasticsearch.yml' do
  source 'elasticsearch.yml.erb'
end

execute 'Restart ES and install kibana' do
  command "sudo service elasticsearch restart"
  command "sudo update-rc.d elasticsearch defaults 95 10"
  command "echo 'deb http://packages.elastic.co/kibana/4.5/debian stable main' | sudo tee -a /etc/apt/sources.list.d/kibana-4.5.x.list"
  command "sudo apt-get update"
  command "sudo apt-get install kibana -y"
end

template '/opt/kibana/config/kibana.yml' do
  source 'kibana.yml.erb'
end

execute 'Restart kibana and install nginx' do
  command "sudo update-rc.d kibana defaults 96 9"
  command "sudo service kibana start"
  command "sudo apt-get install nginx apache2-utils"
  command "sudo htpasswd -c /etc/nginx/htpasswd.users devops3637"
  command "password"
end

template '/etc/nginx/sites-available/proxy.conf' do
  source 'proxy.conf.erb'
  variables server_name: node['nginx']['server_name']
  end

link "/etc/nginx/sites-enabled/proxy.conf" do
  to '/etc/nginx/sites-available/proxy.conf'
 end

  link '/etc/nginx/sites-enabled/default' do
    action :delete
  end

execute 'Restart nginx and install logstash' do
  command "sudo service nginx restart"
  command "echo 'deb http://packages.elastic.co/logstash/2.2/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash-2.2.x.list"
  command "sudo apt-get update"
  command "sudo apt-get install logstash"
  command "sudo mkdir -p /etc/pki/tls/certs"
  command "sudo mkdir /etc/pki/tls/private"
end

template '/etc/ssl/openssl.cnf' do
  source 'openssl.cnf.erb'
  variables ServerPrivateIP: node['ssl']['ServerPrivateIP']
end

execute 'Generate certificate' do
  command "cd /etc/pki/tls"
  command "sudo openssl req -config /etc/ssl/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt"
end

template '/etc/logstash/conf.d/02-beats-input.conf' do
  source '02-beats-input.conf.erb'
end

template '/etc/logstash/conf.d/10-syslog-filter.conf' do
  source '10-syslog-filter.conf.erb'
end

template '/etc/logstash/conf.d/30-elasticsearch-output.conf' do
  source '30-elasticsearch-output.conf.erb'
end

execute 'Restart logstash and configure kibana dashboards' do
  command "sudo service logstash restart"
  command "sudo update-rc.d logstash defaults 96 9"
  command "cd ~"
  command "curl -L -O https://download.elastic.co/beats/dashboards/beats-dashboards-1.1.0.zip"
  command "sudo apt-get -y install unzip"
  command "unzip beats-dashboards-*.zip"
  command "cd beats-dashboards-*"
  command "./load.sh"
  command "cd ~"
  command "curl -O https://gist.githubusercontent.com/thisismitch/3429023e8438cc25b86c/raw/d8c479e2a1adcea8b1fe86570e42abab0f10f364/filebeat-index-template.json"
  command "curl -XPUT 'http://localhost:9200/_template/filebeat?pretty' -d@filebeat-index-template.json"
end
