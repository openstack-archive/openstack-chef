describe port '3306' do
  it { should be_listening }
  its('addresses') { should include '127.0.0.1' }
end

describe service 'mysql' do
  it { should be_running }
  it { should be_enabled }
end

describe mysql_conf.params('mysqld') do
  its('default_storage_engine') { should eq 'InnoDB' }
  its('innodb_autoinc_lock_mode') { should eq '1' }
  its('innodb_file_per_table') { should eq '0' }
  its('innodb_thread_concurrency') { should eq '0' }
  its('innodb_commit_concurrency') { should eq '0' }
  its('innodb_read_io_threads') { should eq '4' }
  its('innodb_flush_log_at_trx_commit') { should eq '1' }
  its('innodb_buffer_pool_size') { should eq '134217728' }
  its('innodb_log_file_size') { should eq '5242880' }
  its('innodb_log_buffer_size') { should eq '8388608' }
  its('character-set-server') { should eq 'latin1' }
  its('query_cache_size') { should eq '0' }
  its('max_connections') { should eq '307' }
end

inspec_version = inspec.version

describe mysql_session('root', 'mypass', '127.0.0.1').query('show databases;') do
  %w(
    ceilometer
    cinder
    designate
    glance
    gnocchi
    heat
    horizon
    ironic
    keystone
    neutron
    nova
    nova_api
    nova_cell0
  ).each do |db|
    # TODO: Work around upstream InSpec issue
    # https://github.com/inspec/inspec/issues/5218
    if Gem::Version.new(inspec_version) >= Gem::Version.new('4.22.2')
      its('output') { should include db }
    else
      its('stdout') { should include db }
    end
  end
end
