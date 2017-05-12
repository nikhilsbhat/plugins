require 'chef/knife'
require "#{File.dirname(__FILE__)}/ec2_elb_base"

class Chef
  class Knife
    class Ec2ElbAddInstance < Knife

      include Chef::Knife::Ec2ElbBase

      banner 'knife ec2 elb add instance (options)'

      option :elb_name,
        :short => '-e ELB-NAME',
        :long => '--elb_name ELB-NAME',
        :description => "The name of load balancer in which the server has to be added"

       option :instance_id,
        :short => '-i INSTANCE-ID',
        :long => '--instance_id INSTANCE-ID',
        :description => 'The ID of instance which has to be added to the LB-pool'

      def run

       elb_name = config[:elb_name]
       instance_id = config[:instance_id]

        elb = connection_elb.register_instances_with_load_balancer({
          instances: [{instance_id: instance_id,},],
          load_balancer_name: elb_name,
        })
        #ec2_ipaddress = set_elb_ip(name,ip)
        elb_details = elb.instances
        puts "#{ui.color('ec2_elb details', :cyan)} : #{elb_details}"
        return elb_details
      end
    end
  end
end
