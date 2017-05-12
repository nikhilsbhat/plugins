require 'chef/knife'
require "#{File.dirname(__FILE__)}/ec2_elb_base"
require "#{File.dirname(__FILE__)}/dengine_server_base"

class Chef
  class Knife
    class DengineElbCreate < Knife

      include Chef::Knife::Ec2ElbBase
      include Chef::Knife::DengineServerBase

      banner 'knife dengine elb create (options)'

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

      option :env,
        :short => '-e ENVIRONMENT',
        :long => '--environment ENVIRONMENT',
        :description => "The id of subnet in which the load balancer that has to be created"

     def run
       name = config[:name]
       env = config[:env]
       protocol = config[:listener_protocol]
       instanceprotocol = config[:listener_instance_protocol]
       loadbalancerport = config[:listener_lb_port]
       instanceport = config[:listener_instance_port]
       sslcertificateid = config[:ssl_certificate_id]

       subnet = get_env(env)
       vpc = get_vpc_id(env)
       sg_group = get_security_group(env)
       subnet_id = ["#{subnet}"]
       security_group = ["#{sg_group}"]

#---------------------Creation of Load Balancer-------------------------------
       elb = connection_elb.create_load_balancer({
          name: name,
          subnets: subnet_id,
          security_groups: security_group,
          scheme: "internet-facing",
          tags: [
            {
               key: "LoadBalancer",
               value: "#{name}-test",
            },
                ],
          ip_address_type: "ipv4",
          })
	   elb_dns = elb.load_balancers.dns_name
       lb_arn = elb.load_balancers.load_balancer_arn

       elb_target_arn = create_target_group(name,protocol,loadbalancerport,vpc)

#---------------------Creation of Listener-------------------------------

         listener = connection_elb.create_listener({	   
         load_balancer_arn: lb_arn, # required
         protocol: protocol, # required, accepts HTTP, HTTPS
         port: loadbalancerport, # required
         default_actions: [ # required
         {
           type: "forward", # required, accepts forward
           target_group_arn: elb_target_arn, # required
         },
         ],
         })
       end
#---------------------Creation of Target Groups-------------------------------

       def create_target_group(name,protocol,loadbalancerport,vpc)
       target = connection_elb.create_target_group({
       name: "Target-#{name}", # required
         protocol: protocol, # required, accepts HTTP, HTTPS
         port: loadbalancerport, # required
         vpc_id: vpc, # required
         health_check_protocol: protocol, # accepts HTTP, HTTPS
         health_check_port: "traffic-port",
         health_check_path: "/index.html",
         health_check_interval_seconds: 30,
         health_check_timeout_seconds: 5,
         healthy_threshold_count: 5,
         unhealthy_threshold_count: 2,
         matcher: {
           http_code: "200", # required
         },
       })
       elb_target = connection_elb.listeners.default_actions.target_group_arn
       return elb_target
       end

#------------------------------------------------------------------------------
    end
  end
end

