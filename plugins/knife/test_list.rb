require 'chef/knife'

class Chef
  class Knife
    class TestList < Knife

        banner "knife test list"

        def run
          node = "nikhil"

          out_put1 = Chef::Search::Query.new
          test1 = out_put1.search('node', "role:maven AND chef_environment:_default")
          puts test1.first

          #response = Hash.new
          out_put = Chef::Search::Query.new
          test = out_put.search(:node, 'role:sensu')
          puts test.first
          #puts out_put.name

          out,newary = Array.new
          search = Chef::Knife::Search.new
          search.name_args = ['node', "role:maven AND chef_environment:production"]
          out = search.run

          nik = out.join(',').to_s
          test = ("#{nik}").tr("[]", '')
          test1 = test.gsub('role', '')
          #puts test1
          newary = test1.split(/,/)
          puts newary

#--------------------------------------------------------------------
        end
    end
  end
end

