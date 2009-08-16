module SecureShellForever
  class << self
    def run(login)
      unless File.exists?(public_key_path)
        STDERR.puts "You do not appear to have a public key. I expected to find one at #{public_key_path}\n"
        STDERR.print "Would you like me to generate one? [Y/n]"
        result = STDIN.gets.strip
        unless result == '' or result == 'y' or result == 'Y'
          flunk %Q{Fair enough, I'll be off then. You can generate your own by hand using\n\n\tssh-keygen -t rsa}
        end
        generate_public_key
      end
      `ssh #{login} "#{remote_command}"`
      puts "Your public key has been copied to the remote server. From now on you can just use plain old 'ssh'. Logging you in..."
      exec "ssh #{login}"
    end

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
      `cat #{public_key_path}`
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
      
      flunk("Unable to generate your public key.") unless File.exists?(public_key_path)
    end
    
    def flunk(message)
      STDERR.puts message
      exit 1
    end
    
    def public_key_path
      File.expand_path('~/.ssh/id_rsa.pub')
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