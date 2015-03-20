# Copyright 2014 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# generate database, schema, and cookie secret key if leader node
bash "db_schema" do
  user node['user']['name']
  cwd "/var/www/#{node['app']}/current"
  environment ({'HOME' => "/home/#{node['user']['name']}"})
  code <<-EOH
    sleep 60
    echo "CREATE DATABASE redmine CHARACTER SET utf8;" | mysql -u #{node['gce']['instance']['attributes']['dbuser']} -p#{node['gce']['instance']['attributes']['dbpassword']} -h #{node['gce']['instance']['attributes']['dbhost']} --ssl --ssl-ca #{node['gce']['instance']['attributes']['secret_base']}/#{node['gce']['instance']['attributes']['sslca']} --ssl-cert #{node['gce']['instance']['attributes']['secret_base']}/#{node['gce']['instance']['attributes']['sslcert']} --ssl-key #{node['gce']['instance']['attributes']['secret_base']}/#{node['gce']['instance']['attributes']['sslkey']}
    RAILS_ENV=production ~/.rbenv/bin/rbenv exec rake db:migrate
  EOH
  only_if { node['gce']['instance']['attributes']['leader']}
end

# generate cookie secret key if leader node
bash "init_secret" do
  user node['user']['name']
  cwd "/var/www/#{node['app']}/current"
  environment ({'HOME' => "/home/#{node['user']['name']}"})
  code <<-EOH
    RAILS_ENV=production ~/.rbenv/bin/rbenv exec rake generate_secret_token
    gsutil cp config/initializers/secret_token.rb gs://#{node['gce']['instance']['attributes']['storage-bucket']}/
  EOH
  only_if { node['gce']['instance']['attributes']['leader']}
end
