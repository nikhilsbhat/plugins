require 'aws-sdk'
require 'chef/knife'
require 'chef/knife/ec2_base'

class Chef
  class Knife
    module Ec2ResourceBase

      def self.included(includer)
        includer.class_eval do
          include Ec2Base

          def connection
            connection ||= begin
              Aws.config.update({credentials: Aws::Credentials.new(Chef::Config[:knife][:aws_access_key_id], Chef::Config[:knife][:aws_secret_access_key])})
            connection = Aws::EC2::Resource.new(region: 'us-west-2')
            end
          end
        end
      end
    end
  end
end
