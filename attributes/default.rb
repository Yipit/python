#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: python
# Attribute:: default
#
# Copyright 2011, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['python']['install_method'] = 'package'

if node['python']['install_method'] == 'package'
  case node['platform']
  when "smartos"
    default['python']['prefix_dir']         = '/opt/local'
  else
    default['python']['prefix_dir']         = '/usr'
  end
else
  default['python']['prefix_dir']         = '/usr/local'
end

default['python']['binary'] = "#{node['python']['prefix_dir']}/bin/python"

default['python']['url'] = 'http://www.python.org/ftp/python'
default['python']['version'] = '2.7.7'
default['python']['checksum'] = '7f49c0a6705ad89d925181e27d0aaa025ee4731ce0de64776c722216c3e66c42'
default['python']['configure_options'] = %W{--prefix=#{node['python']['prefix_dir']}}
default['python']['make_options'] = %W{install}

default['python']['pip_location'] = "#{node['python']['prefix_dir']}/bin/pip"
default['python']['virtualenv_location'] = "#{node['python']['prefix_dir']}/bin/virtualenv"
default['python']['setuptools_version'] = "34.3.3" # this is the latest version on April 7 2017
default['python']['distribute_version'] = "0.7.3"
default['python']['pip_version'] = "8.1.2"
default['python']['virtualenv_version'] = '15.0.2'
