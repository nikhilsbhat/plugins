require 'chef/knife'

class Chef
  class Knife
    module DengineServerBase

      def get_env(env)

        data_item_env = Chef::DataBagItem.new
        data_item_env.data_bag(env)
        data_value_env = Chef::DataBagItem.load(env,env)
        data_env = data_value_env.raw_data['SUBNET-ID']

      end
      def get_security_group(env)
     
        data_item_sg = Chef::DataBagItem.new
        data_item_sg.data_bag(env)
        data_value_sg = Chef::DataBagItem.load(env,env)
        data_sg = data_value_sg.raw_data['SECURITY-ID']

      end
      def get_vpc_id(env)

        data_item_sg = Chef::DataBagItem.new
        data_item_sg.data_bag(env)
        data_value_sg = Chef::DataBagItem.load(env,env)
        data_sg = data_value_sg.raw_data['VPD-ID']

      end
    end
  end
end
