# InSpec test for recipe kibana::default

# The InSpec reference, with examples and extensive documentation, can be
# found at https://www.inspec.io/docs/reference/resources/

describe package "kibana" do
  it { should be_installed }
  its('version') { should match /5\./}
end

describe service "kibana" do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running}
end

describe service "elasticsearch" do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running}
end
