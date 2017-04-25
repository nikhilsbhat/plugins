require 'aws-sdk'
require 'chef/knife'
require 'chef/knife/ec2_base'

class Chef
  class Knife
    module Ec2ClientBase

      def self.included(includer)
        includer.class_eval do
          include Ec2Base

          def connection
            @connection ||= begin
              connection = Aws::EC2::Client.new(
                     region: 'us-west-2',
                     credentials: Aws::Credentials.new(Chef::Config[:knife][:aws_access_key_id], Chef::Config[:knife][:aws_secret_access_key]))
            end
          end

        end
      end
    end
  end
end
