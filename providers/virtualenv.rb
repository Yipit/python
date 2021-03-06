#
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: python
# Provider:: virtualenv
#
# Copyright:: 2011, Opscode, Inc <legal@opscode.com>
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

require 'chef/mixin/shell_out'
require 'chef/mixin/language'
include Chef::Mixin::ShellOut

def whyrun_supported?
  true
end

action :create do
  unless exists?
    directory new_resource.path do
      user new_resource.owner if new_resource.owner
      group new_resource.group if new_resource.group
    end
    Chef::Log.info("Creating virtualenv #{new_resource} at #{new_resource.path}")
    interpreter = new_resource.interpreter ? " --python=#{new_resource.interpreter}" : ""
    execute "#{virtualenv_cmd}#{interpreter} #{new_resource.options} #{new_resource.path}" do
      user new_resource.owner if new_resource.owner
      group new_resource.group if new_resource.group
      environment ({ 'HOME' => ::Dir.home(new_resource.owner) }) if new_resource.owner
    end
    new_resource.updated_by_last_action(true)
  end

  python_pip "Install Venv Setuptools" do
    package_name "setuptools"
    user new_resource.owner if new_resource.owner
    group new_resource.group if new_resource.group
    action :install
    version node['python']['setuptools_version']
    virtualenv new_resource.path
  end

  python_pip "Venv pip" do
    package_name "pip"
    user new_resource.owner if new_resource.owner
    group new_resource.group if new_resource.group
    action :install
    version node['python']['pip_version']
    virtualenv new_resource.path
  end

end

action :delete do
  if exists?
    description = "delete virtualenv #{new_resource} at #{new_resource.path}"
    converge_by(description) do
       Chef::Log.info("Deleting virtualenv #{new_resource} at #{new_resource.path}")
       FileUtils.rm_rf(new_resource.path)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::resource_for_node(:python_virtualenv, node).new(new_resource.name)
  @current_resource.path(new_resource.path)

  if exists?
    cstats = ::File.stat(current_resource.path)
    @current_resource.owner(cstats.uid)
    @current_resource.group(cstats.gid)
  end
  @current_resource
end

def virtualenv_cmd()
  if ::File.exists?(node['python']['virtualenv_location'])
    node['python']['virtualenv_location']
  else
    "virtualenv"
  end
end

private
def exists?
  ::File.exist?(current_resource.path) && ::File.directory?(current_resource.path) \
    && ::File.exists?("#{current_resource.path}/bin/activate")
end
