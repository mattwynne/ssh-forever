Gem::Specification.new do |s|
  s.name = %q{ssh-forever}
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matt Wynne"]
  s.date = %q{2009-09-27}
  s.default_executable = %q{ssh-forever}
  s.description = %q{Provides a replacement for the SSH command which automatically copies your public key while logging in}
  s.email = %q{matt@mattwynne.net}
  s.executables = ["ssh-forever"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.markdown"
  ]
  s.files = [
    ".gitignore",
     "History.txt",
     "LICENSE",
     "README.markdown",
     "VERSION",
     "bin/ssh-forever",
     "lib/ssh-forever.rb",
     "ssh-forever.gemspec"
  ]
  s.add_runtime_dependency('open4', '>= 1.0.1')
  s.homepage = %q{http://github.com/mattwynne/ssh-forever}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Butter-smooth password-less SSH setup.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
