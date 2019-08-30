#
# Cookbook:: java
# Recipe:: default
#
# # Copyright:: 2019, The Authors, All Rights Reserved.

apt_update 'update_sources' do
     action :update
end



package 'openjdk-8-jre-headless'
