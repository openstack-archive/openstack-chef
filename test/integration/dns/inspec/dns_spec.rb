openrc = 'bash -c "source /root/openrc && '

%w(53 953).each do |p|
  describe port p do
    it { should be_listening }
    its('addresses') { should include '127.0.0.1' }
    its('processes') { should include 'named' }
  end
end

describe port '9001' do
  it { should be_listening }
  its('addresses') { should include '127.0.0.1' }
  its('processes') { should include 'designate-api' }
end

describe port '5354' do
  it { should be_listening }
  its('addresses') { should include '0.0.0.0' }
  its('processes') { should include 'designate-mdns' }
end

%w(
  designate-api
  designate-central
  designate-mdns
  designate-producer
  designate-sink
  designate-worker
).each do |designate_service|
  describe service designate_service do
    it { should be_enabled }
    it { should be_running }
  end
end

describe command "#{openrc} designate-manage database version\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^Current: 102 Latest: 102$/ }
end

describe command "#{openrc} openstack dns service list -f value -c service_name -c status\"" do
  its('exit_status') { should eq 0 }
  %w(
    central
    api
    producer
    mdns
    worker
  ).each do |service|
    its('stdout') { should match /^#{service} UP$/ }
  end
end

describe command "#{openrc} openstack zone create --email dnsmaster@example.com example.com.\"" do
  its('exit_status') { should eq 0 }
end

describe command "#{openrc} openstack recordset create --record '10.0.0.1' --type A example.com. www && sleep 20\"" do
  its('exit_status') { should eq 0 }
end

describe command "#{openrc} openstack zone list -f value -c name -c type -c status -c action\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^example.com. PRIMARY ACTIVE NONE$/ }
end

describe command "#{openrc} openstack recordset list example.com. -f value -c name -c type -c records -c status -c action\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^example.com. SOA ns1.example.org. dnsmaster.example.com. [0-9]+ [0-9]+ 600 86400 3600 ACTIVE NONE$/ }
  its('stdout') { should match /^example.com. NS ns1.example.org. ACTIVE NONE$/ }
  its('stdout') { should match /^www.example.com. A 10.0.0.1 ACTIVE NONE$/ }
end

describe command "#{openrc} openstack user list -f value -c Name\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^designate$/ }
end

describe command "#{openrc} openstack service list -f value -c Name -c Type\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^designate dns$/ }
end

describe command "#{openrc} openstack endpoint list -f value -c 'Service Name' -c 'Service Type' -c Enabled -c Interface -c URL\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match %r{designate dns True internal http://127.0.0.1:9001} }
  its('stdout') { should match %r{designate dns True public http://127.0.0.1:9001} }
end
