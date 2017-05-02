require 'chef/knife'
require "#{File.dirname(__FILE__)}/ec2_elb_base"

class Chef
  class Knife
    class Ec2ElbCreate < Knife

      include Chef::Knife::Ec2ElbBase

      banner 'knife ec2 elb create (options)'

      option :listener_protocol,
        :short => '-lp HTTP',
        :long => '--listener-protocol HTTP',
        :description => 'Listener protocol (available: HTTP, HTTPS, TCP, SSL) (default HTTP)',
        :default => 'HTTP'

      option :listener_instance_protocol,
        :short => '-lip HTTP',
        :long => '--listener-instance-protocol HTTP',
        :description => 'Instance connection protocol (available: HTTP, HTTPS, TCP, SSL) (default HTTP)',
        :default => 'HTTP'

      option :listener_lb_port,
        :short => '-lbprot 80',
        :long => '--listener-lb-port 80',
        :description => 'Listener load balancer port (default 80)',
        :default => 80

      option :listener_instance_port,
        :short => '-liport 80',
        :long => '--listener-instance-port 80',
        :description => 'Instance port to forward traffic to (default 80)',
        :default => 80

      option :ssl_certificate_id,
        :short => '-ssl-cert SSL-ID',
        :long => '--ssl-certificate-id SSL-ID',
        :description => 'ARN of the server SSL certificate'

      option :name,
        :short => '-n ELB_NAME',
        :long => '--name ELB_NAME',
        :description => "The name of the elastic load balancer that has to be created"

      option :subnet,
        :short => '-s SUBNET',
        :long => '--subnet SUBNET',
        :description => "The id of subnet in which the load balancer that has to be created"

       option :assign_ip,
        :short => '-as_ip IPADDRESS_FOR_ELB',
        :long => '--assign-ipaddress IPADDRESS_FOR_ELB',
        :description => 'To set ipaddress for ELB, this is optional',
        :boolean => true | false,
        :default => false
	  
      def run
        
       name = config[:name]
       subnet = config[:subnet]
       protocol = config[:listener_protocol]
       instanceprotocol = config[:listener_instance_protocol]
       loadbalancerport = config[:listener_lb_port]
       instanceport = config[:listener_instance_port]
       sslcertificateid = config[:ssl_certificate_id]
       #availability_zones = config[:availability_zones]
       ip = "192.168.10.10"

       elb = connection_elb.create_load_balancer({
         # availability_zones: [
         #   availability_zones, 
         # ], 
          listeners: [
            {
              instance_port: instanceport, 
              instance_protocol: instanceprotocol, 
              load_balancer_port: loadbalancerport, 
              protocol: protocol, 
              ssl_certificate_id: sslcertificateid, 
            }, 
          ], 
          load_balancer_name: name,
          subnets: [
            subnet, 
          ], 
         })

        #ec2_ipaddress = set_elb_ip(name,ip)
        ec2_elb = elb.dns_name
        puts "#{ec2_elb}"
        #puts "#{ec2_ipaddress}"
      end
      def set_elb_ip(name,ip)
        elb_ip = connection_elb.set_ip_address_type({
           load_balancer_arn: name,
           ip_address_type: ip,
         })
      return elb_ip.ip_address_type
      end
    end
  end
end
