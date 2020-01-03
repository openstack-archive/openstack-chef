openrc = 'bash -c "source /root/openrc && '
uuid = /[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/

describe command "#{openrc} neutron lbaas-loadbalancer-create --name test-lb -f shell local_subnet\"" do
  its('exit_status') { should eq 0 }
  [
    /^admin_state_up="True"$/,
    /^name="test-lb"$/,
    /^provider="haproxy"$/,
    /^vip_address="192.168.180.[0-9]+"$/,
  ].each do |line|
    its('stdout') { should match line }
  end
end

describe command "#{openrc} neutron lbaas-loadbalancer-show -f shell test-lb\"" do
  its('exit_status') { should eq 0 }
  [
    /^operating_status="ONLINE"$/,
    /^provisioning_status="ACTIVE"$/,
  ].each do |line|
    its('stdout') { should match line }
  end
end

lb_listener_opts = '--name test-lb-http --loadbalancer test-lb --protocol HTTP --protocol-port 80 -f shell'
describe command "#{openrc} neutron lbaas-listener-create #{lb_listener_opts}\"" do
  its('exit_status') { should eq 0 }
  [
    /^admin_state_up="True"$/,
    /^loadbalancers="\[{u?'id': u?'#{uuid}'}\]"$/,
    /^name="test-lb-http"$/,
    /^protocol="HTTP"$/,
    /^protocol_port="80"$/,
  ].each do |line|
    its('stdout') { should match line }
  end
end

describe command "#{openrc} openstack extension list --network -f value -c Alias\"" do
  its('exit_status') { should eq 0 }
  %w(
    hm_max_retries_down
    l7
    lbaas_agent_schedulerv2
    lbaasv2
    lb-graph
    lb_network_vip
    shared_pools
  ).each do |ext|
    its('stdout') { should match /^#{ext}$/ }
  end
end
