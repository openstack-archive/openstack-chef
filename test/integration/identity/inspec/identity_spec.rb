openrc = 'bash -c "source /root/openrc && '

describe port '5000' do
  it { should be_listening }
  its('addresses') { should include '127.0.0.1' }
end

describe command "#{openrc} openstack user list -f value -c Name\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^admin$/ }
end

describe command("#{openrc} openstack token issue\"") do
  its('stdout') { should match(/expires.*[0-9]{4}-[0-9]{2}-[0-9]{2}/) }
  its('stdout') { should match(/id\s*\|\s[0-9a-z]{32}/) }
  its('stdout') { should match(/project_id\s*\|\s[0-9a-z]{32}/) }
  its('stdout') { should match(/user_id\s*\|\s[0-9a-z]{32}/) }
  its('exit_status') { should eq 0 }
end

describe command "#{openrc} openstack service list -f value -c Name -c Type\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^keystone identity$/ }
end

describe command "#{openrc} openstack endpoint list -f value -c 'Service Name' -c 'Service Type' -c Enabled -c Interface -c URL\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match %r{keystone identity True admin http://127.0.0.1:5000/v3} }
  its('stdout') { should match %r{keystone identity True internal http://127.0.0.1:5000/v3} }
  its('stdout') { should match %r{keystone identity True public http://127.0.0.1:5000/v3} }
end
