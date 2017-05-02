require 'chef/knife'
#require "#{File.dirname(__FILE__)}/ec2_resource_base"
require "#{File.dirname(__FILE__)}/ec2_client_base"

class Chef
  class Knife
    class Ec2SecurityCreate < Knife

      #include Chef::Knife::Ec2ResourceBase
      include Chef::Knife::Ec2ClientBase

      banner 'knife ec2 security create SECU-NAME VPC-ID'

      def run
        unless name_args.size == 2
          show_usage
          Chef::Application.fatal! 'Wrong number of arguments'
        end

        sec_name = name_args[0]
        vpc_id   = name_args[1]

        puts ''
        puts "#{ui.color('security-group-name', :magenta)} : #{sec_name}"
        puts "#{ui.color('vpc-id', :magenta)}              : #{vpc_id}"
        puts ''

          # creation of security group
          security_group = connection_client.create_security_group({
            dry_run: false,
            group_name: "#{sec_name}",
            description: "security-group used by VPC #{sec_name}",
            vpc_id: "#{vpc_id}"
          })
          security_id = security_group.group_id
          connection_client.authorize_security_group_ingress({dry_run: false, group_id: "#{security_id}", ip_protocol: "tcp", from_port: 0, to_port: 65535, cidr_ip: "0.0.0.0/0"})
        #  connection.authorize_security_group_egress({dry_run: false, group_id: "#{security_id}", ip_protocol: "-1"})

          # printing the details of the resources created
         # puts ''
         # puts "#{ui.color('The details of the resource that was created', :cyan)}"
         # puts "#{ui.color('security-id', :magenta)} : #{security_id}"
         # puts ''
         return security_id
      end
    end
  end
end
