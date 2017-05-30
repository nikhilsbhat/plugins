require 'chef/knife'

class Chef
  class Knife
    class CheckList < Knife

        banner "knife check list"

        def run

          test = Chef::Knife::RoleList.new
          test1 = test.run
          puts test1
        end
    end
  end
end

