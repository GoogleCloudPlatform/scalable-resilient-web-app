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

# generate ssl creds for cloudsql and store in GCS
sslkey_local = "#{node['gce']['instance']['attributes']['secret_base']}/#{node['gce']['instance']['attributes']['sslkey']}"
sslkey_remote = "gs://#{node['gce']['instance']['attributes']['storage-bucket']}/#{node['gce']['instance']['attributes']['sslkey']}"
sslcert_local = "#{node['gce']['instance']['attributes']['secret_base']}/#{node['gce']['instance']['attributes']['sslcert']}"
sslcert_remote = "gs://#{node['gce']['instance']['attributes']['storage-bucket']}/#{node['gce']['instance']['attributes']['sslcert']}"
sslca_local = "#{node['gce']['instance']['attributes']['secret_base']}/#{node['gce']['instance']['attributes']['sslca']}"
sslca_remote = "gs://#{node['gce']['instance']['attributes']['storage-bucket']}/#{node['gce']['instance']['attributes']['sslca']}"

bash "init_ssl" do
  user node['user']['name']
  environment ({'HOME' => "/home/#{node['user']['name']}"})
  code <<-EOH
    set -e
    key=redmine-$(date +%s)
    # generate private key, save locally, and restart db
    gcloud sql ssl-certs create $key #{sslkey_local} --instance #{node['gce']['instance']['attributes']['dbinstance']}
    gcloud sql instances restart #{node['gce']['instance']['attributes']['dbinstance']}
    # Retrieve certs and save locally
    gcloud sql ssl-certs describe $key --instance #{node['gce']['instance']['attributes']['dbinstance']} --format json | jq -r '.cert' > #{sslcert_local}
    gcloud sql instances describe #{node['gce']['instance']['attributes']['dbinstance']} --format json | jq -r '.serverCaCert.cert' > #{sslca_local}
    # copy to gcs
    gsutil cp #{sslkey_local} #{sslkey_remote}
    gsutil cp #{sslcert_local} #{sslcert_remote}
    gsutil cp #{sslca_local} #{sslca_remote}
  EOH
  only_if { node['gce']['instance']['attributes']['leader']}
end
