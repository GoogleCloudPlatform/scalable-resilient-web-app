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

sslkey_local = "#{node['gce']['instance']['attributes']['secret_base']}/#{node['gce']['instance']['attributes']['sslkey']}"
sslkey_remote = "gs://#{node['gce']['instance']['attributes']['storage-bucket']}/#{node['gce']['instance']['attributes']['sslkey']}"
sslcert_local = "#{node['gce']['instance']['attributes']['secret_base']}/#{node['gce']['instance']['attributes']['sslcert']}"
sslcert_remote = "gs://#{node['gce']['instance']['attributes']['storage-bucket']}/#{node['gce']['instance']['attributes']['sslcert']}"
sslca_local = "#{node['gce']['instance']['attributes']['secret_base']}/#{node['gce']['instance']['attributes']['sslca']}"
sslca_remote = "gs://#{node['gce']['instance']['attributes']['storage-bucket']}/#{node['gce']['instance']['attributes']['sslca']}"

# wait for ssl file to appear in Cloud Storage, then copy them down
bash "get_ssl_files" do
  user node['user']['name']
  cwd "/var/www/#{node['app']}/current"
  environment ({'HOME' => "/home/#{node['user']['name']}"})
  code <<-EOH
    until gsutil stat #{sslkey_remote} && gsutil stat #{sslcert_remote} && gsutil stat #{sslca_remote}
    do
      echo "Waiting for ssl files..."
      sleep 5
    done
    gsutil cp #{sslkey_remote} #{sslkey_local}
    gsutil cp #{sslcert_remote} #{sslcert_local}
    gsutil cp #{sslca_remote} #{sslca_local}
  EOH
  not_if { node['gce']['instance']['attributes']['leader']}
end
 
# wait for rails secret token to appear in Cloud Storage, then copy it down
bash "get_secret_token" do
  user node['user']['name']
  cwd "/var/www/#{node['app']}/current"
  environment ({'HOME' => "/home/#{node['user']['name']}"})
  code <<-EOH
    until gsutil stat gs://#{node['gce']['instance']['attributes']['storage-bucket']}/secret_token.rb &>/dev/null
    do
      echo "Waiting for secret..."
      sleep 5
    done
    gsutil cp gs://#{node['gce']['instance']['attributes']['storage-bucket']}/secret_token.rb config/initializers/secret_token.rb
  EOH
  not_if { node['gce']['instance']['attributes']['leader']}
end
