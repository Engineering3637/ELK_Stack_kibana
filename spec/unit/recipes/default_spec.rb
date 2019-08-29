#
# Cookbook:: kibana
# Spec:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

require 'spec_helper'

describe 'kibana::default' do
  context 'When all attributes are default, on Ubuntu 18.04' do
    # for a complete list of available platforms and versions see:
    # https://github.com/chefspec/fauxhai/blob/master/PLATFORMS.md
    platform 'ubuntu', '18.04'

  it 'converges successfully' do
    expect { chef_run }.to_not raise_error
  end

  it 'should install elasticsearch' do
    expect(chef_run).to install_package "elasticsearch"
  end

  it 'should install kibana' do
    expect(chef_run).to install_package "kibana"
  end

  it "should enable elasticsearch service" do
    expect(chef_run).to enable_service "elasticsearch"
  end

  it "should enable kibana service" do
    expect(chef_run).to enable_service "kibana"
  end

  it "should start elasticsearch service" do
    expect(chef_run).to start_service "elasticsearch"
  end

  it "should start kibana service" do
    expect(chef_run).to start_service "kibana"
  end

  it 'should add elasticsearch to source list' do
     expect(chef_run).to add_apt_repository('elasticsearch')
   end

   it 'should add kibana to source list' do
      expect(chef_run).to add_apt_repository('kibana')
    end
  end
end
