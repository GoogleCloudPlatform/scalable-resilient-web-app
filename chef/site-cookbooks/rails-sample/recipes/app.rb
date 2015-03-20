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

# create www directory
directory "/var/www" do
  owner node['user']['name']
  group node['group']
  mode 0755
  recursive true
end

# create shared directory structure for app
shared_cfg_path = "/var/www/#{node['app']}/shared/config"
directory shared_cfg_path do
  owner node['user']['name']
  group node['group']
  mode 0755
  recursive true
end

# download redmine
remote_file "#{node['redmine']['download_to']}" do
  source "#{node['redmine']['url']}"
  owner node['user']['name']
  group node['user']['name']
  mode '0644'
end

# install redmine
bash "install_redmine" do
  cwd "#{node['redmine']['tmp_dir']}"
  code <<-EOH
    tar -zxf #{node['redmine']['file_name']}
    mv #{node['redmine']['dir_name']} /var/www/#{node['app']}/current/
    chown -R #{node['user']['name']} /var/www/#{node['app']}/current/
    chgrp -R #{node['user']['name']} /var/www/#{node['app']}/current/
  EOH
end

# Create Gemfile.local
cookbook_file "/var/www/#{node['app']}/current/Gemfile.local" do
  source "Gemfile.local"
  mode 0640
  owner node['user']['name']
  group node['group']
end

# install app gems
bash "gems" do
  user node['user']['name']
  cwd "/var/www/#{node['app']}/current"
  environment ({'HOME' => "/home/#{node['user']['name']}"})
  code "~/.rbenv/bin/rbenv exec bundle install --without development test"
end

# install app gems
bash "ownership" do
  cwd "/var/www/#{node['app']}/current"
  code "chown -R app ."
end
