require 'aws-sdk'
require 'chef/knife'
require 'chef/knife/ec2_base'


module  Engine
  module DengineClientBase

    def self.included(includer)
      includer.class_eval do
        include Ec2Base

        def connection_client
          @connection_client ||= begin
            connection_client = Aws::EC2::Client.new(
                   region: 'us-west-2',
                   credentials: Aws::Credentials.new(Chef::Config[:knife][:aws_access_key_id], Chef::Config[:knife][:aws_secret_access_key]))
          end

        end
      end
    end
  end
end

