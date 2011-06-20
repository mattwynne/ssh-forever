require 'pathname'
require "rubygems"
require "bundler"
Bundler.setup
Bundler.require(:default)
require 'open4'

module SshForever
  ::SshForever::VERSION = '0.4.0' unless defined? ::SshForever::VERSION

  class SecureShellForever
    def initialize(login, options = {})
      @login   = login
      @options = options
      @username, @hostname = @login.split("@")
      cleanup_ssh_config
      cleanup_identity_files
      local_config_path
      initialization_run
      local_key_path
    end

    def initialization_run
      unless File.exists?(config_file_path)
        puts "You do not appear to have a config file. Expected one at #{config_file_path}"  unless @options[:quiet]
        existing_ssh_config? ? append_ssh_config : write_ssh_config
        puts "Next: check for a public key."  unless @options[:quiet]
        unless File.exists?(public_key_path)
          puts "You do not appear to have an identity file/public key. Expected one at #{public_key_path}"  unless @options[:quiet]
          confirm_keygen
          generate_public_key
        end
      end
      args = ssh_args()

      copy_public_key(args)

      puts "Success. From now on you can just use plain old 'ssh'. Logging you in..."  unless @options[:quiet]
      status = run_shell_cmd(ssh_login(args))
      #cleanup_ssh_config
      # exitstatus 2 is when ssh-add can't find an agent on local machine.
      # We ought to switch to use Net::SSH libraries....
      exit 1 unless status.exitstatus.to_i == 0 || status.exitstatus.to_i == 2
    end

    def run_interactive
      system ssh_login_interactive(ssh_args)
      #cleanup_ssh_config
    end

  private

    def local_ssh_config_path
      @local_ssh_config_path ||= Pathname('~/').expand_path.realpath
    end

    def authorized_keys
      (local_ssh_config_path + '.ssh' + 'authorized_keys2').exist? ? 'authorized_keys2' : 'authorized_keys'
    end

    def append_ssh_config
      puts "Appending host entry in local ssh config with name #{@options[:name]}" unless @options[:quiet]
      Pathname(config_file_path).open("a") do |config|
        config << ssh_config
      end
    end

    def write_ssh_config
      puts "Creating host entry in local ssh config with name #{@options[:name]||'ssh-forever'}" unless @options[:quiet]
      Pathname(config_file_path).open("w") do |config|
        config << ssh_config
      end
      @cleanup_ssh_config = config_file_path
    end

    def existing_ssh_config?
      file = Pathname(config_file_path)
      config = file.exist? ? file.read : ""
      chk1 = config[/IdentityFile #{public_key_path}/] ? true : false
      chk2 = config[/Host #{@options[:name]}/] ? true : false
      chk1 && chk2 ? true : false
    end

    def ssh_config
      host_config = <<-STUFF.gsub(/^ {6}/, '')

      Host #{@options[:name]||'ssh-forever'}
        HostName #{@hostname}
        User #{@username}
        Port #{@options[:port]||22}
        IdentityFile #{public_key_path}
        Protocol 2
        PreferredAuthentications publickey
        PubkeyAuthentication yes
        Batchmode yes
        ChallengeResponseAuthentication no
        CheckHostIP yes
        StrictHostKeyChecking #{@options[:strict] ? 'yes' : 'no'}
        HostKeyAlias #{@options[:name] ? @options[:name] : @hostname}
        ConnectionAttempts 3
        ControlMaster auto
        ControlPath #{local_ssh_config_path + '.ssh' + '%h_%p_%r'}
        ForwardAgent no
        ForwardX11Trusted no
        GatewayPorts yes
        GSSAPIAuthentication no
        GSSAPIDelegateCredentials no
        HashKnownHosts yes
        HostbasedAuthentication no
        IdentitiesOnly yes
        LogLevel #{@options[:debug] ? 'DEBUG3' : (@options[:quiet] ? 'QUIET' : 'INFO')}
        NoHostAuthenticationForLocalhost yes
        PasswordAuthentication no
        PermitLocalCommand no
        RekeyLimit 2G
        ServerAliveCountMax #{@options[:intense] ? '1' : '3'}
        ServerAliveInterval #{@options[:intense] ? '1' : '15'}
        TCPKeepAlive yes
        Tunnel no

      STUFF
    end


    def run_shell_cmd(cmd)
      status = ::Open4::popen4('sh') do |pid, stdin, stdout, stderr|
        puts "debug: #{cmd}"  if @options[:debug]
        stdin.puts cmd
        stdin.close
        puts "debug: #{stderr.read.strip}" if @options[:debug]
      end
      status
    end

    def cleanup_ssh_config
      file = "#{local_ssh_config_path + '.ssh' + 'ssh-forever-config'}"
      Pathname(file).delete if Pathname(file).exist?
    end

    def cleanup_identity_files
      file = "#{local_ssh_config_path + '.ssh' + 'ssh-forever-id'}"
      Pathname(file).delete if Pathname(file).exist?
      Pathname(file + '.pub').delete if Pathname(file + '.pub').exist?
    end

    def confirm_keygen
      unless @options[:auto]
        STDERR.print "Would you like me to generate one? [Y/n]"  unless @options[:quiet]
        result = STDIN.gets.strip
        unless result == '' or result == 'y' or result == 'Y'
          cleanup_ssh_config()
          flunk %Q{\nFair enough, I'll be off then. You can generate your own by hand using\n\n    ssh-keygen -t rsa}
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
        ("-F #{@options[:config_file]}" if @options[:config_file]),
        ("-p #{@options[:port]}" if @options[:port] =~ /^\d+$/),
        (@options[:strict] ? "-o stricthostkeychecking=yes" : "-o stricthostkeychecking=no"),
        (@options[:debug] ? "-vvv" : "-q")
      ].compact.join(' ')
    end

    def ssh_keygen
      "ssh-keygen -t rsa #{@options[:debug] ? "-v" : "-q"} -C '#{local_key_path} created by ssh-forever #{Time.now.utc}' -N '' -f #{local_key_path.to_s}"
    end

    def ssh_keycopy(args)
      "ssh-copy-id '-i #{@options[:identity_file]}.pub #{args} #{@login}'"
    end

    def ssh_login(args)
      if @options[:name]
        append_ssh_config unless existing_ssh_config?
        #ssh-add #{@options[:identity_file]};
        login_command = "ssh-add #{@options[:identity_file]}; #{ssh_keycopy(args)}; SSH_AUTH_SOCK=0 ssh #{@options[:name]}#{args} 'echo true;';"
      else
        login_command = "ssh-add #{@options[:identity_file]}; SSH_AUTH_SOCK=0 ssh #{@login}#{args} 'echo true;';"
      end
      login_command
    end

    def ssh_login_interactive(args)
      if @options[:name]
        append_ssh_config unless existing_ssh_config?
        login_command = "ssh #{@options[:name]} #{args}"
      else
        login_command = "ssh #{@login}#{args}"
      end
      login_command
    end

    def flunk(message)
      STDERR.puts message
      exit 1
    end

    def local_key_path
      @options[:identity_file] ||= public_key_path
      if RUBY_VERSION =~ /^1\.8\.7/
        @options[:identity_file] = Pathname(@options[:identity_file]).expand_path.to_s
      else
        @options[:identity_file] = Pathname(@options[:identity_file]).expand_path.realdirpath.to_s
      end
    end

    def local_config_path
      @options[:config_file] ||= config_file_path # public_key_path
      if RUBY_VERSION =~ /^1\.8\.7/
        @options[:config_file] = Pathname(@options[:config_file]).expand_path.to_s
      else
        @options[:config_file] = Pathname(@options[:config_file]).expand_path.realdirpath.to_s
        @options[:config_file]
      end
    end

    def public_key_path
      File.expand_path(@options[:identity_file] || "#{local_ssh_config_path + '.ssh' + 'ssh-forever-id'}")
    end

    def config_file_path
      File.expand_path(@options[:config_file] || "#{local_ssh_config_path + '.ssh' + 'ssh-forever-config'}")
    end

  end
end
