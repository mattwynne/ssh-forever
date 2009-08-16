require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "ssh-forever"
    gem.summary = %Q{Smooth password-less SSH setup}
    gem.description = %Q{Provides a replacement for the SSH command which automatically copies your public key while logging in}
    gem.email = "matt@mattwynne.net"
    gem.homepage = "http://github.com/mattwynne/ssh-forever"
    gem.authors = ["Matt Wynne"]
    gem.bindir = 'bin'
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end
