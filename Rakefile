current_dir = File.dirname(__FILE__)
client_opts = "--chef-license accept --force-formatter --no-color -z --config #{current_dir}/.chef/knife.rb"

task default: ['test']

desc 'Default gate tests to run'
task test: %i(rubocop berks_vendor json_check)

def run_command(command)
  if File.exist?('/opt/chef/bin/chef-client')
    puts "PATH=/opt/chef/embedded/bin:$PATH #{command}"
    sh %(PATH=/opt/chef/embedded/bin:$PATH #{command})
  else
    puts "chef exec #{command}"
    sh %(chef exec #{command})
  end
end

task :destroy_all do
  run_command('rm -rf Gemfile.lock && rm -rf Berksfile.lock && rm -rf cookbooks/')
end

desc 'Vendor your cookbooks/'
task :berks_vendor do
  if ENV['CHEF_MINIMAL'] == 'yes'
    run_command('berks vendor cookbooks')
  else
    berksfile = ENV['PROJECT_DIR'] + '/Berksfile'
    run_command("berks vendor -b #{berksfile} #{current_dir}/cookbooks")
  end
end

desc 'Create Chef Key'
task :create_key do
  unless File.exist?('.chef/validator.pem')
    require 'openssl'
    File.binwrite('.chef/validator.pem', OpenSSL::PKey::RSA.new(2048).to_pem)
  end
end

desc 'Blow everything away'
task clean: [:destroy_all]

# CI tasks
require 'cookstyle'
require 'rubocop/rake_task'
desc 'Run RuboCop'
RuboCop::RakeTask.new do |task|
  task.options << '--display-cop-names'
end

desc 'Validate data bags, environments and roles'
task :json_check do
  require 'json'
  ['data_bags/*', 'environments', 'roles'].each do |sub_dir|
    Dir.glob(sub_dir + '/*.json') do |env_file|
      puts "Checking #{env_file}"
      JSON.parse(File.read(env_file))
    end
  end
end

# Helper for running various testing commands
def _run_commands(desc, commands, openstack = true)
  puts "## Running #{desc}"
  commands.each do |command, options|
    options.each do |option|
      if openstack
        sh %(sudo bash -c '. /root/openrc && #{command} #{option}')
      else
        sh %(#{command} #{option})
      end
    end
  end
  puts "## Finished #{desc}"
end

# use the correct environment depending on platform
if File.exist?('/usr/bin/apt-get')
  @platform = 'ubuntu18'
elsif File.exist?('/usr/bin/yum')
  @platform = 'centos7'
end

# Helper for looking at the starting environment
def _run_env_queries
  _run_commands(
    'basic common env queries', {
      'uname' => ['-a'],
      'pwd' => [''],
      'env' => [''],
      '/opt/chef/embedded/bin/chef-client' => ['--chef-license accept --version'],
      '/opt/chef/embedded/bin/inspec' =>
        [
          'version --chef-license accept',
          'detect --chef-license accept',
        ],
    },
    false
  )
  case @platform
  when 'ubuntu18'
    _run_commands(
      'basic debian env queries', {
        'ifconfig' => [''],
        'cat' => ['/etc/apt/sources.list'],
      },
      false
    )
  when 'centos7'
    _run_commands(
      'basic rhel env queries', {
        '/usr/sbin/ip' => ['addr'],
        'cat' => ['/etc/yum.repos.d/*'],
      },
      false
    )
  end
end

def _save_logs(prefix, log_dir)
  sh %(sleep 25)
  sh %(mkdir -p #{log_dir}/#{prefix})
  sh %(sudo journalctl -l > #{log_dir}/#{prefix}/journalctl.log)
  case @platform
  when 'ubuntu18'
    sh %(sudo /bin/ss -tunlp > #{log_dir}/#{prefix}/netstat.log)
  when 'centos7'
    sh %(sudo /sbin/ss -tunlp > #{log_dir}/#{prefix}/netstat.log)
  end
  %w(
    apache2
    ceilometer
    cinder
    designate
    glance
    gnocchi
    heat
    httpd
    keystone
    mariadb
    mysql
    mysql-default
    neutron
    nova
    openvswitch
    rabbitmq
  ).each do |project|
    sh %(mkdir -p #{log_dir}/#{prefix}/#{project})
    sh %(sudo cp -rL /etc/#{project} #{log_dir}/#{prefix}/#{project}/etc || true)
    sh %(sudo cp -rL /var/log/#{project} #{log_dir}/#{prefix}/#{project}/log || true)
  end
end

desc 'Integration test on Infra'
task integration: %i(create_key berks_vendor) do
  log_dir = ENV['WORKSPACE'] + '/logs'
  sh %(mkdir #{log_dir})
  # Translates project name into shorter names with underscores
  project_name = ENV['PROJECT_NAME'].gsub('cookbook-openstack-', '').tr('-', '_')
  # Use special roles for openstack-chef and cookbook-openstackclient projects
  project_name =
    case project_name
    when 'openstack_chef'
      'minimal'
    when 'cookbook_openstackclient'
      'openstackclient'
    when 'integration_test'
      'integration'
    else
      project_name
    end
  if ENV['CHEF_MINIMAL'] == 'yes'
    # If CHEF_MINIMAL is set, then let's assume we're running the full minimal suite
    project_name = 'minimal'
  end
  inspec_dir = 'test/integration/' + project_name.tr('_', '-') + '/inspec'
  run_list = "role[#{project_name}],role[#{project_name}_test]"
  # This is a workaround for allowing chef-client to run in local mode
  sh %(sudo mkdir -p /etc/chef && sudo cp .chef/encrypted_data_bag_secret /etc/chef/openstack_data_bag_secret)
  _run_env_queries

  # Three passes to ensure idempotency. prefer each to times, even if it
  # reads weird
  (1..3).each do |i|
    begin
      puts "####### Pass #{i}"
      # Kick off chef client in local mode, will converge OpenStack right on the gate job "in place"
      sh %(sudo chef-client #{client_opts} -E integration -r '#{run_list}' > #{log_dir}/chef-client-pass#{i}.txt 2>&1)
    rescue => e
      raise "####### Pass #{i} failed with #{e.message}"
    ensure
      # make sure logs are saved, pass or fail
      _save_logs("pass#{i}", log_dir)
      sh %(sudo chown -R $USER #{log_dir}/pass#{i})
      sh %(sudo chmod -R go+rx #{log_dir}/pass#{i})
    end
  end

  # Run InSpec & Tempest tests
  puts '## InSpec & Tempest'
  begin
    sh %(sudo /opt/chef/embedded/bin/inspec exec --no-color #{inspec_dir} --reporter=cli html:#{log_dir}/inspec.html)
    if File.exist?('/opt/tempest-venv/tempest.sh')
      # Run Tempest separately from InSpec due to no way of extending the command timeout beyond 600s
      # https://github.com/inspec/inspec/issues/3866
      sh %(sudo /opt/tempest-venv/tempest.sh)
    else
      puts 'Skipping Tempest tests...'
    end
  rescue => e
    raise "####### InSpec & Tempest failed with #{e.message}"
  ensure
    # make sure logs are saved, pass or fail
    _save_logs('inspec', log_dir)
    sh %(sudo chown -R $USER #{log_dir}/inspec)
    sh %(sudo chmod -R go+rx #{log_dir}/inspec)
  end
end
