apt_update 'update_sources' do
  action :update
end

package 'tree' do
action :install
end
