glance_service = os.family == 'redhat' ? 'openstack-glance-api' : 'glance-api'
openrc = 'bash -c "source /root/openrc && '

describe port '9292' do
  it { should be_listening }
  its('addresses') { should include '127.0.0.1' }
end

describe service glance_service do
  it { should be_enabled }
  it { should be_running }
end

describe command "#{openrc} glance-manage db_version\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should include 'rocky' }
end

describe command "#{openrc} openstack image list -f value -c Name\"" do
  its('exit_status') { should eq 0 }
  %w(
    cirros
    cirros-test1
    cirros-test2
  ).each do |image|
    its('stdout') { should match /^#{image}$/ }
  end
end

describe command "#{openrc} openstack user list -f value -c Name\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^glance$/ }
end

describe command "#{openrc} openstack service list -f value -c Name -c Type\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^glance image$/ }
end

describe command "#{openrc} openstack endpoint list -f value -c 'Service Name' -c 'Service Type' -c Enabled -c Interface -c URL\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match %r{glance image True internal http://127.0.0.1:9292} }
  its('stdout') { should match %r{glance image True public http://127.0.0.1:9292} }
end
