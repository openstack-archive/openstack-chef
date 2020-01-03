# openstack-common::etcd
describe service 'etcd-openstack' do
  it { should be_enabled }
  it { should be_running }
end

# openstack-common::etcd
describe package 'bash-completion' do
  it { should be_installed }
end

describe file '/etc/bash_completion.d/osc.bash_completion' do
  it { should exist }
  its('content') { should match /_openstack/ }
end
