require 'chef/knife'

class Chef
  class Knife
    class TestList < Knife

        banner "knife test list"

        def run
          node = "j*"

          response = Hash.new
          Chef::Search::Query.new.search(:role, "name:#{node}") do |n|
          response[n.name] = n 
          end
          puts  response

          out,newary = Array.new
          search = Chef::Knife::Search.new
          search.name_args = ['role', "name:#{node}"]
          out = search.run

          nik = out.join(',').to_s
          test = ("#{nik}").tr("[]", '')
          test1 = test.gsub('role', '')
          #puts test1
          newary = test1.split(/,/)
          puts newary
        end
    end
  end
end

