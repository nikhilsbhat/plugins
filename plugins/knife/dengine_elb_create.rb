require 'chef/knife'
require "#{File.dirname(__FILE__)}/dengine_elb_base"
require "#{File.dirname(__FILE__)}/dengine_server_base"

module Engine
    class DengineElbCreate < Chef::Knife

      include DengineElbBase
      include DengineServerBase

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

       subnet = get_subnet_id(env)
       vpc = get_vpc_id(env)
       sg_group = get_security_group(env)
       subnet_id1 = subnet.first
       subnet_id2 = subnet.last
       security_group = ["#{sg_group}"]

       # creation of load balancer
       puts "#{ui.color('creating load balancer for the environment', :cyan)}"
       elb_details = create_loadbalancer(name,subnet_id1,subnet_id2,security_group)
       elb_dns = elb_details.first
       elb_arn = elb_details.last
       puts "#{ui.color('load balancer created', :cyan)}"
       puts ""

       # creation of target group
       puts "#{ui.color('creating target group for the load balancer created', :cyan)}"
       elb_target_arn = create_target_group(name,protocol,loadbalancerport,vpc)
       puts "#{ui.color('target group created', :cyan)}"
       puts ""

       # creation of listeners
       puts "#{ui.color('creating listeners for the load balancer created', :cyan)}"
       lb_listeners = create_listeners(elb_arn,protocol,loadbalancerport,elb_target_arn)
       puts "#{ui.color('listeners created', :cyan)}"
       puts ""

       # creating and adding data to data_bag
       users = Chef::DataBag.new
       users.name("#{name}")
       users.create
       data = {
              'id' => "#{name}",
              'ELB-NAME' => "#{name}",
              'TARGET-GROUP-ARN' => ["#{elb_target_arn}"],
              'ELB_DNS' => "#{elb_dns}",
              'ELB_ARN' => "#{elb_arn}"
              }
       databag_item = Chef::DataBagItem.new
       databag_item.data_bag("#{name}")
       databag_item.raw_data = data
       databag_item.save

       # printing details of the loadbalancers
       puts "#{ui.color('Printing details', :magenta)}"
       puts "First subnet value #{subnet_id1}"
       puts "First subnet value #{subnet_id2}"

     end
#---------------------Creation of Load Balancer-------------------------------

     def create_loadbalancer(name,subnet_id1,subnet_id2,security_group)
       elb = connection_elb.create_load_balancer({
          name: name,
          subnets: [subnet_id1,subnet_id2,],
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
       lb_dns = elb.load_balancers[0].dns_name
       lb_arn = elb.load_balancers[0].load_balancer_arn

       return lb_dns,lb_arn
     end

#---------------------Creation of Listener-------------------------------

     def create_listeners(elb_arn,protocol,loadbalancerport,elb_target_arn)
       listener = connection_elb.create_listener({
       load_balancer_arn: elb_arn, # required
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
       elb_target = target.target_groups[0].target_group_arn
       return elb_target
     end

#------------------------------------------------------------------------------
  end
end
