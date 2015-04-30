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

# base config
default['app'] = "rails-sample"
default['group'] = "app"
default['user']['name'] = "app"
default['ruby']['version'] = "2.1.2"

# SSL config for database
default['gce']['instance']['attributes']['secret_base']	= '/tmp'
default['gce']['instance']['attributes']['sslkey'] = 'client-key.pem'
default['gce']['instance']['attributes']['sslcert'] = 'client-cert.pem'
default['gce']['instance']['attributes']['sslca'] = 'server-ca.pem'

# Redmine source
default['redmine']['version'] = '2.6.0'
default['redmine']['dir_name'] = "redmine-#{default['redmine']['version']}"
default['redmine']['file_name'] = "#{default['redmine']['dir_name']}.tar.gz"
default['redmine']['tmp_dir'] = '/tmp'
default['redmine']['download_to'] =  "#{default['redmine']['tmp_dir']}/#{default['redmine']['file_name']}"
default['redmine']['url'] = "http://www.redmine.org/releases/#{default['redmine']['file_name']}"

# Redmine S3 plugin
default['redmine_s3_plugin']['url'] = "https://github.com/ka8725/redmine_s3/archive/af4ef4faa2247e31a5b859ef99b2674f3f7e4846.tar.gz"
default['redmine_s3_plugin']['file_name'] = "af4ef4faa2247e31a5b859ef99b2674f3f7e4846.tar.gz"
default['gce']['instance']['attributes']['gcs-access-key'] = ""
default['gce']['instance']['attributes']['gcs-secret'] = ""

# The attributes below are expected to be set as metadata on GCE instances
# and made available by Ohai. If you are using Vagrant to deploy, you'll
# need to set these manually

# Cloud Storage bucket that SSL and cookie signing token use
default['gce']['instance']['attributes']['storage-bucket'] = ""

# Target CloudSQL database
default['gce']['instance']['attributes']['dbinstance'] = ""
default['gce']['instance']['attributes']['dbname'] = ""
default['gce']['instance']['attributes']['dbuser'] = ""
default['gce']['instance']['attributes']['dbhost'] = ""
default['gce']['instance']['attributes']['dbpassword'] = ""
