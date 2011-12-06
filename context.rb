## knife-context
## Knife plugin to manage your knife.rb and credentials for multiple Chef Servers.

require 'chef/knife'

module Rkive
  class Context < Chef::Knife
    
    banner "knife context list
knife context show
knife context switch CONTEXT
knife context create CONTEXT
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

      if !File.directory?("#{@my_home}/chef/contexts") then
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

      case command
      when "list"
        context_list
      when "show"
        context_show
      when "switch"
        context_switch
      when "create"
        ui.warn "PLACEHOLDER - We will create a new context"
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
      ui.msg "\nAvailible Contexts:"
      Dir.entries("#{@my_home}/.chef/contexts").each do |dir|
        ("#{dir}" == "." || "#{dir}" == "..") ? nil : ui.msg("#{dir}")
      end
    end

  end
end
