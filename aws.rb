## knife-context
## Knife plugin to manage your knife.rb and credentials for multiple Chef Servers.

require 'chef/knife'
require 'erb'

module Rkive
  class Aws < Chef::Knife

    banner "knife aws list
knife aws show
knife aws switch CONTEXT
knife aws create CONTEXT
knife aws delete CONTEXT
knife aws disable
knife aws enable
knife aws verbose
knife aws quiet"

    def run
      # Startup:
      # Check for ~/.ec2/contexts directory, create it if neccessary
      @my_home="#{ENV['HOME']}"
      if !File.directory?("#{@my_home}/.ec2/") then
        Dir.mkdir("#{@my_home}/.ec2/")
        ui.warn "#{@my_home}/.ec2/ Wasn't found, so we created it."
      end

      if !File.directory?("#{@my_home}/.ec2/contexts") then
        Dir.mkdir("#{@my_home}/.ec2/contexts")
        ui.warn "#{@my_home}/.ec2/contexts Wasn't found, so we created it."
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
      Dir.entries("#{@my_home}/.ec2/contexts").each do |dir|
        ("#{dir}" == "." || "#{dir}" == "..") ? nil : ui.msg("#{dir}")
      end
    end

    def context_show
      if File.exists?("#{@my_home}/.ec2/configured_context") then
        current_context=File.readlink("#{@my_home}/.ec2/configured_context")
        basename=File.basename(current_context)
        ui.msg "Current ec2 Context is: #{basename}"
      else
        ui.warn "No ec2 context selected"
      end
    end

    def context_switch
      if @new_context.nil? then
        ui.error "You must provide a context to switch to."
        exit 1
      end

      context_status_file="#{@my_home}/.ec2/contexts/#{@new_context}"
      context_status_link="#{@my_home}/.ec2/configured_context"

      context_credential_file="#{@my_home}/.ec2/contexts/#{@new_context}/aws_credential_file"
      context_credential_link="#{@my_home}/.ec2/aws_credential_file"

      context_cert_file="#{@my_home}/.ec2/contexts/#{@new_context}/cert-.pem"
      context_cert_link="#{@my_home}/.ec2/cert-.pem"
      
      context_pk_file="#{@my_home}/.ec2/contexts/#{@new_context}/pk-.pem"
      context_pk_link="#{@my_home}/.ec2/pk-.pem"
      
      context_fog_file="#{@my_home}/.ec2/contexts/#{@new_context}/fog"
      context_fog_link="#{@my_home}/.fog"

      contexts = [
        [context_status_file, context_status_link],
        [context_credential_file, context_credential_link],
        [context_cert_file, context_cert_link],
        [context_pk_file, context_pk_link],
        [context_fog_file, context_fog_link]
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
      # if @context_user.nil? then
      #   ui.error "You must provide a user for the context."
      #   exit 1
      # end
      # if @context_fqdn.nil? then
      #   ui.error "You must provide a fqdn to switch to. (i.e. chef.example.com)"
      #   exit 1
      # end

      if File.exists?("#{@my_home}/.ec2/contexts/#{@new_context}") then
      else
        Dir.mkdir("#{@my_home}/.ec2/contexts/#{@new_context}", 0755)
      end

      ui.msg "about to create skeleton"
      if context_skeleton then
        ui.msg "Context succsfully created. Be sure to copy aws_credential_file, cert-.pem and pk-.pem to #{@my_home}/.ec2/#{@new_context}"
      else
        ui.error "Context Creation Failed"
        exit 1
      end
    end

    def context_skeleton
      return true
    end
    
  end
end
