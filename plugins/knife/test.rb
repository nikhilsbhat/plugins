require 'chef/knife'

class Chef
  class Knife
    class Test < Knife

        banner "knife test"

        def run

          test = []
          role = [["java-tomcat-acceptance-0","java-tomcat-acceptance-1"],"java-mysql-acceptance-0"]
          env = "acceptance"
          x = role[0]
          puts x[0]
          test = get_nodes(role,env)

#          test.each do |node|
#            ip = fetch_ipaddress(node)
#            puts ip
#          end

          #puts test.to_s
          #.tr("[]", '').tr('node', '')
        end

        def get_nodes(role,env)
          node_found = []
          n = role.size-1
          role.each {|i|
                     node_query = Chef::Search::Query.new
                     node_found[n] = node_query.search('node', "name:#{i} AND chef_environment:#{env}").first
                     n -=1
          }

          return node_found
        end

    def fetch_ipaddress(node)

      search = Chef::Knife::Search.new
      search.name_args = ['node', "name:#{node}"]
      out = search.run
      ip = Array.new
      out.each do |node|
      ip = node["cloud_v2"]["public_ipv4"]
      end
      return ip

    end

    end
  end
end
