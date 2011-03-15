require 'pathname'
require "rubygems"
require "bundler"
Bundler.setup
Bundler.require

module SshForever
  VERSION = '0.3.0'

  class SecureShellForever
    def initialize(login, options = {})
      @login   = login
      @options = options
      local_key_path
    end

    def run
      unless File.exists?(public_key_path)
        STDERR.puts "You do not appear to have a public key. I expected to find one at #{public_key_path}"  unless @options[:quiet]
        confirm_keygen
        generate_public_key
      end

      args = ssh_args()

      copy_public_key(args)

      puts "Success. From now on you can just use plain old 'ssh'. Logging you in..."  unless @options[:quiet]
      status = run_shell_cmd(ssh_login(args))
      exit 1 unless status.exitstatus.to_i == 0
      if @options[:login]
        if @options[:name]
          `ssh #{@options[:name]}#{args}`   #TODO: fix this so that remote session is left open
        else
          `ssh #{@login}#{args}`
        end
      end
    end

  private

    def local_ssh_config_path
      @local_ssh_config_path ||= Pathname('~/').expand_path.realpath
    end

    def authorized_keys
      (local_ssh_config_path + '.ssh' + 'authorized_keys2').exist? ? 'authorized_keys2' : 'authorized_keys'
    end

    def append_ssh_config
      puts "Creating host entry in local ssh config with name #{@options[:name]}" unless @options[:quiet]
      (local_ssh_config_path + '.ssh' + 'config').open("a") do |config|
        config << ssh_config
      end
    end

    def existing_ssh_config?
      config = (local_ssh_config_path + '.ssh' + 'config').read
      chk1 = config[/IdentityFile #{public_key_path}/] ? true : false
      chk2 = config[/Host #{@options[:name]}/] ? true : false
      chk1 && chk2 ? true : false
    end

    def ssh_config
      host_config = <<-STUFF.gsub(/^ {6}/, '')

      Host #{@options[:name]}
        HostName #{@login.split("@")[1]}
        User #{@login.split("@")[0]}
        PreferredAuthentications publickey
        IdentityFile #{public_key_path}
        StrictHostKeyChecking #{@options[:strict] ? 'true' : 'false'}
        HostKeyAlias #{@options[:name]}
      STUFF
    end


    def run_shell_cmd(cmd)
      status = Open4::popen4('sh') do |pid, stdin, stdout, stderr|
        puts "debug: #{cmd}"  if @options[:debug]
        stdin.puts cmd
        stdin.close
      end
      status
    end

    def confirm_keygen
      unless @options[:auto]
        STDERR.print "Would you like me to generate one? [Y/n]"  unless @options[:quiet]
        result = STDIN.gets.strip
        unless result == '' or result == 'y' or result == 'Y'
          flunk %Q{Fair enough, I'll be off then. You can generate your own by hand using\n\n\tssh-keygen -t rsa}
        end
      end
    end


    def generate_public_key
      status = run_shell_cmd(ssh_keygen)
      flunk("Oh dear. I was unable to generate your public key. Run the command 'ssh-keygen -t rsa' manually to find out why.") unless status.exitstatus.to_i == 0
    end

    def copy_public_key(args)
      puts "Copying your public key to the remote server."  unless @options[:quiet]
      puts "Prepare to enter your password for the last time..." unless @options[:quiet]
      status = run_shell_cmd(ssh_keycopy(args))
      exit 1 unless status.exitstatus.to_i == 0
    end

    def ssh_args
      [ ' ',
        ("-p #{@options[:port]}" if @options[:port] =~ /^\d+$/),
        (@options[:strict] ? "-o stricthostkeychecking=yes" : "-o stricthostkeychecking=no"),
        (@options[:debug] ? "-vvv" : "-q")
      ].compact.join(' ')
    end

    def ssh_keygen
      "ssh-keygen -t rsa #{@options[:debug] ? "-v" : "-q"} -C '#{local_key_path} created by ssh-forever #{Time.now.utc}' -N '' -f #{local_key_path}"
    end

    def ssh_keycopy(args)
      "ssh-copy-id '-i #{@options[:identity_file]} #{args} #{@login}'"
    end

    def ssh_login(args)
      if @options[:name]
        append_ssh_config unless existing_ssh_config?
        login_command = "ssh-add; SSH_AUTH_SOCK=0 ssh #{@options[:name]}#{args} 'ssh-add;';"
      else
        login_command = "ssh-add; SSH_AUTH_SOCK=0 ssh #{@login}#{args} 'ssh-add;';"
      end
      login_command
    end


    def flunk(message)
      STDERR.puts message
      exit 1
    end

    def local_key_path
      @options[:identity_file] = Pathname(@options[:identity_file]).expand_path.realdirpath.to_s
    end

    def public_key_path
      File.expand_path(@options[:identity_file] || "#{local_ssh_config_path + '.ssh' + 'id_rsa.pub'}")
    end

  end
end
