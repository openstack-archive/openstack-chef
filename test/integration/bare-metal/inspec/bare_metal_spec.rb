ironic_service = os.family == 'redhat' ? 'openstack-ironic-conductor' : 'ironic-conductor'
openrc = 'bash -c "source /root/openrc && '

describe port '6385' do
  it { should be_listening }
  its('addresses') { should include '127.0.0.1' }
end

describe service ironic_service do
  it { should be_enabled }
  it { should be_running }
end

describe command "#{openrc} openstack baremetal node create --driver ipmi\"" do
  its('exit_status') { should eq 0 }
end

describe command "#{openrc} openstack baremetal chassis create\"" do
  its('exit_status') { should eq 0 }
end

describe command "#{openrc} openstack baremetal node list -f value -c 'Provisioning State'\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^enroll$/ }
end

describe command "#{openrc} openstack baremetal chassis list -f value -c Description\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^None$/ }
end

describe command "#{openrc} openstack user list -f value -c Name\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^ironic$/ }
end

describe command "#{openrc} openstack service list -f value -c Name -c Type\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^ironic bare_metal$/ }
end

describe command "#{openrc} openstack endpoint list -f value -c 'Service Name' -c 'Service Type' -c Enabled -c Interface -c URL\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match %r{ironic bare_metal True public http://127.0.0.1:6385} }
  its('stdout') { should match %r{ironic bare_metal True internal http://127.0.0.1:6385} }
end
