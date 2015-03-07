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

# create unicorn config file
shared_cfg_path = "/var/www/#{node['app']}/shared/config"
template "#{shared_cfg_path}/unicorn.rb" do
  source "unicorn.rb.erb"
  mode 0640
  owner node['user']['name']
  group node['group']
end

# create unicorn init
template "/etc/init.d/unicorn_#{node['app']}" do
  source "unicorn.sh.erb"
  mode 0755
  owner node['user']['name']
  group node['group']
end

# add init script link
execute "update-rc.d unicorn_#{node['app']} defaults" do
  not_if "ls /etc/rc2.d | grep unicorn_#{node['app']}"
end

# start service
service "unicorn_#{node['app']}" do
  supports :restart => true
  action [ :enable, :start ]
end
