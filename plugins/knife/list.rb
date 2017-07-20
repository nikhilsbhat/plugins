require 'chef/knife'

class Chef
  class Knife
    class CheckList < Knife

        banner "knife check list"

        def run
        new_version = '2.0'
        #exec = Chef::Knife::Exec.new
        #exec.config[:exec] = "nodes.find(:name => 'dengine-test-machine') { |node|  node.set['dengine']['app']['version'] = #{new_version} ; node.save; }"
        #exec.run
          
          #node_name = node[dengine-test-machine]
          #node_name = Array.new
          #Chef::Log.info "Preparing node #{node_name.name} for deployment"
          #  value.override['dengine']['app']['version'] = new_version
          #  value.save
          #puts "#{value}"
          



#---------------------------------------------------------------------------------
        search = Chef::Knife::Search.new
        search.name_args = ['node', "name:deploy-machine"]
        out = search.run
        puts out
        value = Array.new
        out.each do |node|
        node.set['dengine']['artifact']['deployment']  = 'false'
        node.save
        end
        puts "Node name is set"
#--------------------------------------------------------------------------------
        end
    end
  end
end

