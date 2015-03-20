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

# create database.yml file
template "/var/www/#{node['app']}/current/config/database.yml" do
  source "database.yml.erb"
  mode 0640
  owner node['user']['name']
  group node['group']
end

# install gems one more time to pickup mysql
bash "gems" do
  user node['user']['name']
  cwd "/var/www/#{node['app']}/current"
  environment ({'HOME' => "/home/#{node['user']['name']}"})
  code "~/.rbenv/bin/rbenv exec bundle install --without development test"
end
