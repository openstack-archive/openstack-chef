openrc = 'bash -c "source /root/openrc && '

%w(
  8041
  8042
).each do |p|
  describe port p do
    it { should be_listening }
    its('addresses') { should include '127.0.0.1' }
  end
end

telemetry_services =
  if os.family == 'redhat'
    %w(
      openstack-ceilometer-central
      openstack-ceilometer-notification
      gnocchi-metricd
    )
  else
    %w(
      ceilometer-agent-central
      ceilometer-agent-notification
      gnocchi-metricd
    )
  end

telemetry_services.each do |telemetry_service|
  describe service telemetry_service do
    it { should be_enabled }
    it { should be_running }
  end
end

# TODO: Add tests for 'openstack metric list' which requires setting up
# a redis server and fixing the api-paste.ini file we provide.

describe command "#{openrc} openstack user list -f value -c Name\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^gnocchi$/ }
  its('stdout') { should match /^ceilometer$/ }
end

describe command "#{openrc} openstack service list -f value -c Name -c Type\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^ceilometer metering$/ }
  its('stdout') { should match /^gnocchi metric$/ }
  its('stdout') { should match /^aodh alarming$/ }
end

describe command "#{openrc} openstack endpoint list -f value -c 'Service Name' -c 'Service Type' -c Enabled -c Interface -c URL\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match %r{aodh alarming True internal http://127.0.0.1:8042} }
  its('stdout') { should match %r{aodh alarming True public http://127.0.0.1:8042} }
  its('stdout') { should match %r{ceilometer metering True internal http://127.0.0.1} }
  its('stdout') { should match %r{ceilometer metering True public http://127.0.0.1} }
  its('stdout') { should match %r{gnocchi metric True internal http://127.0.0.1:8041} }
  its('stdout') { should match %r{gnocchi metric True public http://127.0.0.1:8041} }
end
