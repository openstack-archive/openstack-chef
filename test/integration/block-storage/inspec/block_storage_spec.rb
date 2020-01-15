openrc = 'bash -c "source /root/openrc && '

cinder_services =
  if os.family == 'redhat'
    %w(
      openstack-cinder-backup
      openstack-cinder-scheduler
      openstack-cinder-volume
    )
  else
    %w(
      cinder-backup
      cinder-scheduler
      cinder-volume
    )
  end

describe port '8776' do
  it { should be_listening }
  its('addresses') { should include '127.0.0.1' }
end

cinder_services.each do |cinder_service|
  describe service cinder_service do
    it { should be_enabled }
    it { should be_running }
  end
end

describe command "#{openrc} cinder-manage db version\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^123$/ }
end

describe command "#{openrc} openstack user list -f value -c Name\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^cinder$/ }
end

describe command "#{openrc} openstack service list -f value -c Name -c Type\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^cinderv2 volumev2$/ }
  its('stdout') { should match /^cinderv3 volumev3$/ }
end

describe command "#{openrc} openstack endpoint list -f value -c 'Service Name' -c 'Service Type' -c Enabled -c Interface -c URL\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match %r{cinderv2 volumev2 True internal http://127.0.0.1:8776/v2/%\(tenant_id\)s} }
  its('stdout') { should match %r{cinderv2 volumev2 True public http://127.0.0.1:8776/v2/%\(tenant_id\)s} }
  its('stdout') { should match %r{cinderv3 volumev3 True internal http://127.0.0.1:8776/v3/%\(tenant_id\)s} }
  its('stdout') { should match %r{cinderv3 volumev3 True public http://127.0.0.1:8776/v3/%\(tenant_id\)s} }
end
