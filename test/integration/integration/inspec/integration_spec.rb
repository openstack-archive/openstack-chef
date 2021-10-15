openrc = 'bash -c "source /root/openrc && '
platform = os.family
os_release = os.release.to_i

describe command "#{openrc} openstack network show local_net -f shell -c admin_state_up -c status\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should include 'admin_state_up="True"' }
  its('stdout') { should include 'status="ACTIVE"' }
end

describe command "#{openrc} openstack subnet show local_subnet -f shell -c enable_dhcp -c cidr -c allocation_pools\"" do
  its('exit_status') { should eq 0 }
  case platform
  when 'debian'
    its('stdout') do
      should include 'allocation_pools="[{\'start\': \'192.168.180.2\', \'end\': \'192.168.180.254\'}]"'
    end
  when 'redhat'
    if os_release >= 8
      its('stdout') do
        should include 'allocation_pools="[{\'start\': \'192.168.180.2\', \'end\': \'192.168.180.254\'}]"'
      end
    else
      its('stdout') do
        should include 'allocation_pools="[{u\'start\': u\'192.168.180.2\', u\'end\': u\'192.168.180.254\'}]'
      end
    end
  end
  its('stdout') { should include 'cidr="192.168.180.0/24"' }
  its('stdout') { should include 'enable_dhcp="True"' }
end

describe port '53' do
  it { should be_listening }
  its('processes') { should include 'named' }
  its('protocols') { should include 'tcp' }
  its('protocols') { should include 'udp' }
end

describe port '953' do
  it { should be_listening }
  its('processes') { should include 'named' }
  its('protocols') { should include 'tcp' }
end

os_family = os.family

case os_family
when 'redhat'
  service_name = 'named'
  service_path = 'named'
  service_user = 'named'
when 'debian'
  service_name = 'bind9'
  service_path = 'bind'
  service_user = 'bind'
end

describe service service_name do
  it { should be_enabled }
  it { should be_running }
end

describe file "/etc/#{service_path}/rndc.key" do
  its('owner') { should cmp service_user }
  its('group') { should cmp service_user }
  its('mode') { should cmp '0440' }
  its('content') { should match /secret "nN4XQnMMhIeWpQHz0l6qG5UUj1WMEKLqHJSwl8fcR1I=";/ }
end

describe file "/etc/#{service_path}/named.designate" do
  its('owner') { should cmp service_user }
  its('group') { should cmp service_user }
end

describe file '/etc/resolv.conf' do
  its('content') { should match /nameserver 1.0.0.1/ }
  its('content') { should match /nameserver 8.8.8.8/ }
end

describe file '/tmp/heat_key.priv' do
  its('content') { should match /BEGIN RSA PRIVATE KEY/ }
end

describe command "#{openrc} openstack flavor show m1.small\"" do
  its('exit_status') { should eq 0 }
end

describe file '/tmp/heat.yml' do
  it { should exist }
end

describe command '/opt/tempest-venv/bin/tempest --version' do
  its('exit_status') { should eq 0 }
  case os_family
  when 'redhat'
    if os_release >= 8
      its('stdout') { should match /^tempest 22.1.0$/ }
    else
      its('stderr') { should match /^tempest 22.1.0$/ }
    end
  when 'debian'
    its('stdout') { should match /^tempest 22.1.0$/ }
  end
end

describe file '/opt/tempest-venv/tempest.sh' do
  its('mode') { should cmp '0755' }
end

describe file '/opt/tempest/etc/tempest-blacklist' do
  it { should exist }
end

describe file '/opt/tempest/etc/tempest.conf' do
  it { should exist }
end
