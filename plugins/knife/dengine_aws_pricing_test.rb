require 'chef/knife'
require "#{File.dirname(__FILE__)}/base/dengine_client_base"

module Engine
  class DengineAwsTest < Chef::Knife

    include DengineClientBase

    deps do
      require 'fog/aws'
    end

    banner "knife dengine aws test (options)"

    def run

      fetch_pricing_info

    end

    def fetch_date

      current_time = DateTime.now

      date = current_time.strftime "%Y-%m-%d"
      return date

    end

    def fetch_pricing_info

      puts "#{ui.color('Fetching the list of services, please hold your stance', :cyan)}"
      puts "#{ui.color('*****************************', :cyan)}"
      service = aws_pricing_list.describe_services({
#        service_code: "ServiceCode",
        format_version: "aws_v1",
      })

      service.services.each do |i|
        puts i.service_code
      end

    end

  end
end
