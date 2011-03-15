@announce @glacial
Feature: SSH client configuration file

  In order to run ssh-forever consistently and easily
  As a user of SSH-Forever
  I want a SSH client configuration file


  Scenario: With all options
    Given I run `ssh-forever hedge@localhost --debug --port 22 --strict --intense --name this --identity_file my_id --config_file config.file --batch` interactively
     Then the file "config.file" should contain "Host this"
      And the file "config.file" should contain "  Port 22"
      And the file "config.file" should match /  IdentityFile (.*)my_id/
      And the file "config.file" should contain "  StrictHostKeyChecking yes"
      And the file "config.file" should contain "  HostKeyAlias this"
      And the file "config.file" should match /  ControlPath (.*)%h_%p_%r/
      And the file "config.file" should contain "  LogLevel QUIET"
      And the file "config.file" should contain "  ServerAliveCountMax 1"
      And the file "config.file" should contain "  ServerAliveInterval 1"
