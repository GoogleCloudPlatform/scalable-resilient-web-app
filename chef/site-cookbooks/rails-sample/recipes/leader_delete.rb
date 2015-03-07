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

bash "copy_logs" do
  code <<-EOH
    gsutil cp /var/log/startupscript.log gs://#{node['gce']['instance']['attributes']['storage-bucket']}/logs/$(date +"%Y-%m-%d")/$HOSTNAME/
  EOH
  only_if { node['gce']['instance']['attributes']['leader']}
end

bash "delete_self" do
  code <<-EOH
    FULL_ZONE=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")
    ZONE="${FULL_ZONE##*/}"
    gcloud compute instances delete $HOSTNAME --zone $ZONE
  EOH
  only_if { node['gce']['instance']['attributes']['leader']}
end

