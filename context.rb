## knife-context
## Knife plugin to manage your knife.rb and credentials for multiple Chef Servers.

require 'chef/knife'
require 'erb'

module Rkive
  class Context < Chef::Knife

    banner "knife context list
knife context show
knife context switch CONTEXT
knife context create CONTEXT USER URL
knife context delete CONTEXT
knife context disable
knife context enable
knife context verbose
knife context quiet"

    def run
      # Startup:
      # Check for ~/.chef/contexts directory, create it if neccessary
      @my_home="#{ENV['HOME']}"
      if !File.directory?("#{@my_home}/.chef/") then
        Dir.mkdir("#{@my_home}/.chef/")
        ui.warn "#{@my_home}/.chef/ Wasn't found, so we created it."
      end

      if !File.directory?("#{@my_home}/.chef/contexts") then
        Dir.mkdir("#{@my_home}/.chef/contexts")
        ui.warn "#{@my_home}/.chef/contexts Wasn't found, so we created it."
      end

      if @name_args[0].nil? then
        ui.warn "Using default show"
        command = "show"
      else
        command = @name_args[0]
      end
      @new_context = @name_args[1]
      @context_user = @name_args[2]
      @context_fqdn = @name_args[3]

      case command
      when "list"
        context_list
      when "show"
        context_show
      when "switch"
        context_switch
      when "create"
        context_create
      when "delete"
        ui.warn "PLACEHOLDER - We will delete the named context"
      when "disable"
        ui.warn "PLACEHOLDER - We will disable knife-context"
      when "enable"
        ui.warn "PLACEHOLDER - We will enable knife-context"
      when "verbose"
        ui.warn "PLACEHOLDER - We will print the context before running any knife commands"
      when "quiet"
        ui.warn "PLACEHOLDER - We will stop being verbose"
      end

    end

    def context_list
      ui.msg "\nAvailible Contexts:"
      Dir.entries("#{@my_home}/.chef/contexts").each do |dir|
        ("#{dir}" == "." || "#{dir}" == "..") ? nil : ui.msg("#{dir}")
      end
    end

    def context_show
      if File.exists?("#{@my_home}/.chef/configured_context") then
        current_context=File.readlink("#{@my_home}/.chef/configured_context")
        basename=File.basename(current_context)
        ui.msg "Current Knife Context is: #{basename}"
      else
        ui.warn "No knife context selected"
      end
    end

    def context_switch
      if @new_context.nil? then
        ui.error "You must provide a context to switch to."
        exit 1
      end

      context_status_file="#{@my_home}/.chef/contexts/#{@new_context}"
      context_status_link="#{@my_home}/.chef/configured_context"
      
      context_config_file="#{@my_home}/.chef/contexts/#{@new_context}/knife.rb"
      context_config_link="#{@my_home}/.chef/knife.rb"
      
      context_pem_file="#{@my_home}/.chef/contexts/#{@new_context}/client.pem"
      context_pem_link="#{@my_home}/.chef/client.pem"

      contexts = [
        [context_status_file, context_status_link],
        [context_config_file, context_config_link],
        [context_pem_file, context_pem_link]
      ]
        
      contexts.each do |target,link|
        if File.exists?(target) then
          File.exists?(link) ? File.unlink(link) : nil
          File.symlink(target, link)
        else
          ui.error "#{target} within Context '#{@new_context}' do not seem to exist."
        end
      end

    end

    def context_create
      if @new_context.nil? then
        ui.error "You must provide a context to create."
        exit 1
      end
      if @context_user.nil? then
        ui.error "You must provide a user for the context."
        exit 1
      end
      if @context_fqdn.nil? then
        ui.error "You must provide a fqdn to switch to. (i.e. chef.example.com)"
        exit 1
      end

      if File.exists?("#{@my_home}/.chef/contexts/#{@new_context}") then
      else
        Dir.mkdir("#{@my_home}/.chef/contexts/#{@new_context}", 0755)
      end

      ui.msg "about to create skeleton"
      if context_skeleton then
        ui.msg "Context succsfully created. Be sure to copy client.pem and validation.pem to #{@my_home}/.chef/#{@new_context}"
      else
        ui.error "Context Creation Failed"
        exit 1
      end
    end

    def context_skeleton
      new_knife_file = "#{@my_home}/.chef/contexts/#{@new_context}/knife.rb"

      if File.exists?(new_knife_file) then
        ui.msg "#{new_knife_file} already exists"
      else
        ui.msg "Creating skeleton file"
        skeleton = ERB.new <<-EOF
current_dir = File.dirname(__FILE__)
user = "<%= @context_user %>"
server = "<%= @context_fqdn %>"

log_level                :info
log_location             STDOUT
node_name                "\#{user}"
client_key               "\#{current_dir}/client.pem"
validation_client_name   "chef-validator"
validation_key           "\#{current_dir}/chef/validation.pem"
chef_server_url          "https://\#{server}"
cache_type               "BasicFile"
cache_options( :path => "\#{current_dir}/checksums" )
cookbook_path            ["\#{current_dir}/../chef-repo/cookbooks"]
        EOF

        result = skeleton.result(binding)

        skeleton_file = File.new(new_knife_file,'w')
        skeleton_file.puts result
        skeleton_file.close
        ui.msg "Created context skeleton"
        return true
      end

    end

  end
end
