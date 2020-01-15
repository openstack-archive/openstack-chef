%w(80 443).each do |p|
  describe port p do
    it { should be_listening }
    its('addresses') { should include '0.0.0.0' }
  end
end

# Simulate logging into horizon with curl and test the output to ensure the
# application is running correctly
horizon_command =
  # 1. Get initial cookie for curl
  # 2. Grab the CSRF token
  # 3. Try logging into the site with the token
  'curl -so /dev/null -k -c c.txt -b c.txt https://localhost/auth/login/ && ' \
  'token=$(grep csrftoken c.txt | cut -f7) &&' \
  'curl -H \'Referer:https://localhost/auth/login/\' -k -c c.txt -b c.txt -d ' \
  '"login=admin&password=admin&csrfmiddlewaretoken=${token}" -v ' \
  'https://localhost/auth/login/ 2>&1'

describe command(horizon_command) do
  its('stdout') { should match(/subject: CN=controller.example.com/) }
  its('stdout') { should match(/< HTTP.*200 OK/) }
  its('stdout') { should_not match(/CSRF verification failed. Request aborted./) }
end
