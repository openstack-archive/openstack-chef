openrc = 'bash -c "source /root/openrc && '

domain_id = inspec.command("#{openrc} openstack domain show test-domain -f value -c id\"").stdout.chomp
project_id = inspec.command("#{openrc} openstack project show test-project -f value -c id\"").stdout.chomp
endpoint_id = inspec.command("#{openrc} openstack endpoint list --service test-service -f value -c ID\"").stdout.chomp
role_id = inspec.command("#{openrc} openstack role show test-role -f value -c id\"").stdout.chomp

describe command "#{openrc} openstack domain show test-domain -f shell\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^enabled="True"$/ }
  its('stdout') { should match /^name="test-domain"$/ }
end

describe command "#{openrc} openstack project show test-project -f shell\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^enabled="True"$/ }
  its('stdout') { should match /^name="test-project"$/ }
  its('stdout') { should match /^domain_id="#{domain_id}"$/ }
  its('stdout') { should match /^parent_id="#{domain_id}"$/ }
end

describe command "#{openrc} openstack role assignment list --user test-user -f value\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /#{role_id}/ }
  its('stdout') { should match /#{domain_id}/ }
end

describe command "#{openrc} openstack role assignment list --user test-user-revoke -f value\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should_not match /#{role_id}/ }
  its('stdout') { should_not match /#{domain_id}/ }
end

describe command "#{openrc} openstack user show test-user -f shell\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^name="test-user"$/ }
  its('stdout') { should match /^domain_id="#{domain_id}"$/ }
  its('stdout') { should match /^enabled="True"$/ }
  its('stdout') { should match /^default_project_id="#{project_id}"$/ }
  its('stdout') { should match /^email="defaultmail"$/ }
end

describe command "#{openrc} openstack service show test-service -f shell\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^name="test-service"$/ }
  its('stdout') { should match /^enabled="True"$/ }
  its('stdout') { should match /^type="foobar"$/ }
end

describe command "#{openrc} openstack endpoint show #{endpoint_id} -f shell\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^name="test-endpoint"$/ }
  its('stdout') { should match /^enabled="True"$/ }
  its('stdout') { should match /^interface="admin"$/ }
  its('stdout') { should match /^region="RegionOne"$/ }
  its('stdout') { should match /^region_id="RegionOne"$/ }
  its('stdout') { should match /^service_name="test-service"$/ }
  its('stdout') { should match /^service_type="foobar"$/ }
  its('stdout') { should match %r{^url="http://127\.0\.0\.1:9999/v1"$} }
end

describe command "#{openrc} openstack domain list -f value\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /test-domain/ }
  its('stdout') { should_not match /test-domain-delete/ }
end

describe command "#{openrc} openstack project list -f value\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /test-project/ }
  its('stdout') { should_not match /test-project-delete/ }
end

describe command "#{openrc} openstack role list -f value\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /test-role/ }
  its('stdout') { should_not match /test-role-delete/ }
end

describe command "#{openrc} openstack user list -f value\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /test-user/ }
  its('stdout') { should_not match /test-user-delete/ }
end

describe command "#{openrc} openstack service list -f value\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /test-service/ }
  its('stdout') { should_not match /test-service-delete/ }
end

describe command "#{openrc} openstack endpoint list -f value\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match %r{http://127.0.0.1:9999/v1} }
  its('stdout') { should_not match %r{http://127.0.0.1:9998/v1} }
end
