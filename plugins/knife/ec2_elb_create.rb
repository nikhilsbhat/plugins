require 'chef/knife'
require "#{File.dirname(__FILE__)}/ec2_elb_base"

class Chef
  class Knife
    class Ec2ElbCreate < Knife

      include Chef::Knife::Ec2ElbBase

      banner 'knife ec2 elb create (options)'

      option :listener_protocol,
        :long => '--listener-protocol HTTP',
        :description => 'Listener protocol (available: HTTP, HTTPS, TCP, SSL) (default HTTP)',
        :default => 'HTTP'

      option :listener_instance_protocol,
        :long => '--listener-instance-protocol HTTP',
        :description => 'Instance connection protocol (available: HTTP, HTTPS, TCP, SSL) (default HTTP)',
        :default => 'HTTP'

      option :listener_lb_port,
        :long => '--listener-lb-port 80',
        :description => 'Listener load balancer port (default 80)',
        :default => 80

      option :listener_instance_port,
        :long => '--listener-instance-port 80',
        :description => 'Instance port to forward traffic to (default 80)',
        :default => 80

      option :ssl_certificate_id,
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

      def run

       name = config[:name]
       subnet = config[:subnet]
       protocol = config[:listener_protocol]
       instanceprotocol = config[:listener_instance_protocol]
       loadbalancerport = config[:listener_lb_port]
       instanceport = config[:listener_instance_port]
       sslcertificateid = config[:ssl_certificate_id]
       #availability_zones = config[:availability_zones]

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
        puts "#{ui.color('ec2_elb dns_name', :cyan)} : #{ec2_elb}"
        return ec2_elb
      end
    end
  end
end
