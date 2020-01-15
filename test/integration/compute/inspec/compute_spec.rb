%w(
  6080
  8774
  8775
  8778
).each do |p|
  describe port p do
    it { should be_listening }
    its('addresses') { should include '127.0.0.1' }
  end
end

nova_services =
  if os.family == 'redhat'
    %w(
      openstack-nova-compute
      openstack-nova-conductor
      openstack-nova-consoleauth
      openstack-nova-novncproxy
      openstack-nova-scheduler
    )
  else
    %w(
      nova-compute
      nova-conductor
      nova-consoleauth
      nova-novncproxy
      nova-scheduler
    )
  end

nova_services.each do |nova_service|
  describe service nova_service do
    it { should be_enabled }
    it { should be_running }
  end
end

openrc = 'bash -c "source /root/openrc && '

describe command "#{openrc} nova-manage version\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^18.[0-9]+/ }
end

describe command "#{openrc} nova-manage db version\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^390$/ }
end

describe command "#{openrc} openstack user list -f value -c Name\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^nova$/ }
  its('stdout') { should match /^placement$/ }
end

describe command "#{openrc} openstack service list -f value -c Name -c Type\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^nova compute$/ }
  its('stdout') { should match /^nova-placement placement$/ }
end

describe command "#{openrc} openstack endpoint list -f value -c 'Service Name' -c 'Service Type' -c Enabled -c Interface -c URL\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match %r{nova compute True public http://127.0.0.1:8774/v2.1/%\(tenant_id\)s} }
  its('stdout') { should match %r{nova compute True internal http://127.0.0.1:8774/v2.1/%\(tenant_id\)s} }
  its('stdout') { should match %r{nova-placement placement True public http://127.0.0.1:8778} }
  its('stdout') { should match %r{nova-placement placement True internal http://127.0.0.1:8778} }
end
