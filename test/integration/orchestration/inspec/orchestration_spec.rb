openrc = 'bash -c "source /root/openrc && '

%w(
  8000
  8004
).each do |p|
  describe port p do
    it { should be_listening }
    its('addresses') { should include '127.0.0.1' }
  end
end

heat_services =
  if os.family == 'redhat'
    %w(
      openstack-heat-api-cfn
      openstack-heat-api
      openstack-heat-engine
    )
  else
    %w(
      heat-api-cfn
      heat-api
      heat-engine
    )
  end

heat_services.each do |heat_service|
  describe service heat_service do
    it { should be_enabled }
    it { should be_running }
  end
end

describe command "#{openrc} heat-manage db_version\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^86$/ }
end

describe command("#{openrc} openstack stack create -t /tmp/heat.yml stack\"") do
  its('exit_status') { should eq 0 }
end

describe command("#{openrc} openstack stack show stack -c stack_status -f value\"") do
  its('exit_status') { should eq 0 }
  its('stdout') { should match(/^CREATE_IN_PROGRESS|CREATE_COMPLETE$/) }
end

describe command("#{openrc} openstack stack delete -y stack\"") do
  its('exit_status') { should eq 0 }
end

describe command "#{openrc} openstack user list -f value -c Name\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^heat_domain_admin$/ }
  its('stdout') { should match /^heat$/ }
end

describe command "#{openrc} openstack service list -f value -c Name -c Type\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match /^heat-cfn cloudformation$/ }
  its('stdout') { should match /^heat orchestration$/ }
end

describe command "#{openrc} openstack endpoint list -f value -c 'Service Name' -c 'Service Type' -c Enabled -c Interface -c URL\"" do
  its('exit_status') { should eq 0 }
  its('stdout') { should match %r{heat orchestration True internal http://127.0.0.1:8004/v1/%\(tenant_id\)s} }
  its('stdout') { should match %r{heat orchestration True public http://127.0.0.1:8004/v1/%\(tenant_id\)s} }
  its('stdout') { should match %r{heat-cfn cloudformation True public http://127.0.0.1:8000/v1} }
  its('stdout') { should match %r{heat-cfn cloudformation True internal http://127.0.0.1:8000/v1} }
end

describe command "#{openrc} openstack orchestration resource type list -f value\"" do
  its('exit_status') { should eq 0 }
  %w(
    AWS::AutoScaling::AutoScalingGroup
    AWS::AutoScaling::LaunchConfiguration
    AWS::AutoScaling::ScalingPolicy
    AWS::CloudFormation::Stack
    AWS::CloudFormation::WaitCondition
    AWS::CloudFormation::WaitConditionHandle
    AWS::EC2::InternetGateway
    AWS::EC2::SecurityGroup
    AWS::ElasticLoadBalancing::LoadBalancer
    AWS::IAM::AccessKey
    AWS::IAM::User
    AWS::RDS::DBInstance
    OS::Heat::AccessPolicy
    OS::Heat::AutoScalingGroup
    OS::Heat::CloudConfig
    OS::Heat::Delay
    OS::Heat::DeployedServer
    OS::Heat::InstanceGroup
    OS::Heat::MultipartMime
    OS::Heat::None
    OS::Heat::RandomString
    OS::Heat::ResourceChain
    OS::Heat::ResourceGroup
    OS::Heat::ScalingPolicy
    OS::Heat::SoftwareComponent
    OS::Heat::SoftwareConfig
    OS::Heat::SoftwareDeployment
    OS::Heat::SoftwareDeploymentGroup
    OS::Heat::Stack
    OS::Heat::StructuredConfig
    OS::Heat::StructuredDeployment
    OS::Heat::StructuredDeploymentGroup
    OS::Heat::TestResource
    OS::Heat::UpdateWaitConditionHandle
    OS::Heat::Value
    OS::Heat::WaitCondition
    OS::Heat::WaitConditionHandle
    OS::Keystone::Domain
    OS::Keystone::Endpoint
    OS::Keystone::Group
    OS::Keystone::GroupRoleAssignment
    OS::Keystone::Project
    OS::Keystone::Region
    OS::Keystone::Role
    OS::Keystone::Service
    OS::Keystone::User
    OS::Keystone::UserRoleAssignment
  ).each do |resource|
    its('stdout') { should match /^#{resource}$/ }
  end
end
