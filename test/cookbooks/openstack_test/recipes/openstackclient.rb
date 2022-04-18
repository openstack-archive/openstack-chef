class ::Chef::Recipe
  include ::Openstack
end

identity_endpoint = internal_endpoint 'identity'
auth_url = identity_endpoint.to_s
admin_user = 'admin'
admin_pass = get_password 'user', admin_user
admin_project = 'admin'
admin_domain = 'default'

connection_params = {
  openstack_auth_url: auth_url,
  openstack_username: admin_user,
  openstack_api_key: admin_pass,
  openstack_project_name: admin_project,
  openstack_domain_name: admin_domain,
}

%w(
  test-domain-delete
  test-project-delete
  test-role-delete
  test-user-delete
  test-user-revoke
  test-service-delete
  test-endpoint-delete
).each do |r|
  file "/tmp/#{r}" do
    action :nothing
  end
end

# Create tests
openstack_domain 'test-domain' do
  connection_params connection_params
end

openstack_project 'test-project' do
  domain_name 'test-domain'
  connection_params connection_params
end

openstack_role 'test-role' do
  connection_params connection_params
end

openstack_user 'test-user' do
  role_name 'test-role'
  project_name 'test-project'
  domain_name 'test-domain'
  connection_params connection_params
  action [:create, :grant_role, :grant_domain]
end

openstack_service 'test-service' do
  type 'foobar'
  connection_params connection_params
end

openstack_endpoint 'test-endpoint' do
  service_name 'test-service'
  interface 'admin'
  url 'http://127.0.0.1:9999/v1'
  region 'RegionOne'
  connection_params connection_params
end

# Delete tests
openstack_domain 'test-domain-delete' do
  connection_params connection_params
  notifies :create, 'file[/tmp/test-domain-delete]'
  not_if { ::File.exist?('/tmp/test-domain-delete') }
end

openstack_domain 'test-domain-delete' do
  connection_params connection_params
  action :delete
end

openstack_project 'test-project-delete' do
  connection_params connection_params
  notifies :create, 'file[/tmp/test-project-delete]'
  not_if { ::File.exist?('/tmp/test-project-delete') }
end

openstack_project 'test-project-delete' do
  connection_params connection_params
  action :delete
end

openstack_role 'test-role-delete' do
  connection_params connection_params
  notifies :create, 'file[/tmp/test-role-delete]'
  not_if { ::File.exist?('/tmp/test-role-delete') }
end

openstack_user 'test-user-revoke' do
  role_name 'test-role'
  project_name 'test-project'
  domain_name 'test-domain'
  connection_params connection_params
  notifies :create, 'file[/tmp/test-user-revoke]'
  not_if { ::File.exist?('/tmp/test-user-revoke') }
  action [:create, :grant_role, :grant_domain]
end

openstack_user 'test-user-revoke' do
  role_name 'test-role'
  project_name 'test-project'
  domain_name 'test-domain'
  connection_params connection_params
  action [:revoke_role, :revoke_domain]
end

openstack_role 'test-role-delete' do
  connection_params connection_params
  action :delete
end

openstack_user 'test-user-delete' do
  connection_params connection_params
  notifies :create, 'file[/tmp/test-user-delete]'
  not_if { ::File.exist?('/tmp/test-user-delete') }
end

openstack_user 'test-user-delete' do
  connection_params connection_params
  action :delete
end

openstack_service 'test-service-delete' do
  type 'foobar'
  connection_params connection_params
  notifies :create, 'file[/tmp/test-service-delete]'
  not_if { ::File.exist?('/tmp/test-service-delete') }
end

openstack_service 'test-service-delete' do
  type 'foobar'
  connection_params connection_params
  action :delete
end

openstack_endpoint 'test-endpoint-delete' do
  service_name 'test-service'
  interface 'public'
  url 'http://127.0.0.1:9998/v1'
  region 'RegionOne'
  connection_params connection_params
  notifies :create, 'file[/tmp/test-endpoint-delete]'
  not_if { ::File.exist?('/tmp/test-endpoint-delete') }
end

openstack_endpoint 'test-endpoint-delete' do
  service_name 'test-service'
  interface 'public'
  url 'http://127.0.0.1:9998/v1'
  region 'RegionOne'
  connection_params connection_params
  action :delete
end
