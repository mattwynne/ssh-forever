module SshForever
  VERSION = '0.2.1'

  class SecureShellForever
    def initialize(login, options = {})
      @login   = login
      @options = options
    end

    def run
      unless File.exists?(public_key_path)
        STDERR.puts "You do not appear to have a public key. I expected to find one at #{public_key_path}\n"
        STDERR.print "Would you like me to generate one? [Y/n]"
        result = STDIN.gets.strip
        unless result == '' or result == 'y' or result == 'Y'
          flunk %Q{Fair enough, I'll be off then. You can generate your own by hand using\n\n\tssh-keygen -t rsa}
        end
        generate_public_key
      end

      args = [
          ' ',
          ("-p #{@options[:port]}" if @options[:port] =~ /^\d+$/)
        ].compact.join(' ')

      puts "Copying your public key to the remote server. Prepare to enter your password for the last time."
      `ssh #{@login}#{args} "#{remote_command}"`
      exit 1 unless $?.exitstatus == 0

      if @options[:name]
        puts "Creating host entry in local ssh config with name #{@options[:name]}"
        File.open(File.expand_path("~/.ssh/config"), "a") do |config|
          #ah heredocs, how I hate you...
          host_config = <<-STUFF

Host #{@options[:name]}
HostName #{@login.split("@")[1]}
User #{@login.split("@")[0]}
          STUFF
          config << host_config
        end
        login_command = "ssh #{@options[:name]}#{args}"
      else
        login_command = "ssh #{@login}#{args}"
      end

      puts "Success. From now on you can just use plain old 'ssh'. Logging you in..."
      exec login_command
    end

  private

    def remote_command
      commands = []
      commands << 'mkdir -p ~/.ssh'
      commands << 'chmod 700 ~/.ssh'
      commands << 'touch ~/.ssh/authorized_keys'
      commands << 'chmod 700 ~/.ssh/authorized_keys'
      commands << "echo #{key} >> ~/.ssh/authorized_keys"
      commands.join(' && ')
    end

    def key
      `cat #{public_key_path}`.strip
    end

    def generate_public_key
      silence_stream(STDOUT) do
        silence_stream(STDERR) do
          pipe = IO.popen('ssh-keygen -t rsa', 'w')
          6.times do
            pipe.puts "\n"
          end
        end
      end
      Process.wait
      flunk("Oh dear. I was unable to generate your public key. Run the command 'ssh-keygen -t rsa' manually to find out why.") unless $? == 0
    end

    def flunk(message)
      STDERR.puts message
      exit 1
    end

    def public_key_path
      File.expand_path(@options[:identity_file] || '~/.ssh/id_rsa.pub')
    end

    def silence_stream(stream)
      old_stream = stream.dup
      stream.reopen(RUBY_PLATFORM =~ /mswin/ ? 'NUL:' : '/dev/null')
      stream.sync = true
      yield
    ensure
      stream.reopen(old_stream)
    end
  end
end
