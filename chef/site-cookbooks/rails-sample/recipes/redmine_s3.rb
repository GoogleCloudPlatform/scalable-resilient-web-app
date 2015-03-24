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

# download s3 plugin
remote_file "/var/www/#{node['app']}/current/plugins/#{node['redmine_s3_plugin']['file_name']}" do
  source "#{node['redmine_s3_plugin']['url']}"
  owner node['user']['name']
  group node['user']['name']
  mode '0644'
  not_if { node['gce']['instance']['attributes']['gcs-access-key'] == "disabled" }
end

# install s3 plugin
bash "install_s3_plugin" do
  cwd "/var/www/#{node['app']}/current/plugins"
  code <<-EOH
    tar -zxf #{node['redmine_s3_plugin']['file_name']}
  EOH
  not_if { node['gce']['instance']['attributes']['gcs-access-key'] == "disabled" }
end

# create s3.yml file
template "/var/www/#{node['app']}/current/config/s3.yml" do
  source "s3.yml.erb"
  mode 0640
  owner node['user']['name']
  group node['group']
  not_if { node['gce']['instance']['attributes']['gcs-access-key'] == "disabled" }
end

# install gems one more time to pickup redmine_s3
bash "gems" do
  user node['user']['name']
  cwd "/var/www/#{node['app']}/current"
  environment ({'HOME' => "/home/#{node['user']['name']}"})
  code "~/.rbenv/bin/rbenv exec bundle install --without development test"
  not_if { node['gce']['instance']['attributes']['gcs-access-key'] == "disabled" }
end
