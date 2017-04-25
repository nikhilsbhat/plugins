require 'chef/knife'

class Chef
  class Knife
    module CreateServerBase

      def set_env(env)
        if env == 'uat'
          vpc = 'subnet-40e57d09'
        elsif env == 'mngt'
          vpc = 'mngt-vpc@123'
        elsif env == 'prod'
          vpc = 'prod-vpc@123'
        else
          print ("you have not selected the proper vpc, else vpc doesn't exists")
        end
      end

    end
  end
end
