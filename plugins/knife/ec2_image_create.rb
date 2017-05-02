require 'chef/knife'
require "#{File.dirname(__FILE__)}/ec2_client_base"

class Chef
  class Knife
    class Ec2ImageCreate < Knife

      include Chef::Knife::Ec2ClientBase

      banner 'knife ec2 image create INSTANCE-ID IMAGE-NAME DESCRIPTION'

      def run
        unless name_args.size == 3
          show_usage
          Chef::Application.fatal! 'Wrong number of arguments'
        end

        instance_id = name_args[0]
        image_name = name_args[1]
        image_description = name_args[2]

        puts ''
        puts "#{ui.color('instance_id', :magenta)} : #{instance_id}"
        puts "#{ui.color('image_name', :magenta)}  : #{image_name}"
        puts ''

        option = ui.ask_question( "The above mentioned are the details for the image creation, would you like to proceed...?  [y/n]", opts = {:default => 'n'})


        if option == "y"

          puts " "
          puts "#{ui.color('We are capturing required image for you', :cyan)}"
          puts "."
          image = connection_client.create_image(instance_id: "#{instance_id}", name: "#{image_name}", description: "#{image_description}",)
          image_id = image.image_id
          #puts "#{image_id}"
          connection_client.create_tags({ resources: ["#{image_id}"], tags: [{ key: 'Name', value: "#{image_name}" }]})
          #printing the details of the resources created
          puts ""
          puts "#{ui.color('The details of the resource created', :cyan)}"
          puts ""
          puts "#{ui.color('image_id', :magenta)}         : #{image_id}"
          puts "#{ui.color('image_name', :magenta)}       : #{image_name}"
          puts ""

        else
          puts "#{ui.color('...You have opted to move out of image creation...', :cyan)}"
        end

        return image_id
      end
    end
  end
end

