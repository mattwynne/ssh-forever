@announce @slow
Feature: Run interactively

  In order to run ssh-forever interactively
  As a user of SSH-Forever
  I want interactive mode as default

  Scenario: Check ssh-forever binary being used
    Given I successfully run `which ssh-forever`
    Then the stdout should contain "/usr/src/ssh-forever/bin/ssh-forever"

  Scenario: Without a key
    Given I run `ssh-forever hedge@localhost` interactively
     When I type "n"
      And the output should contain:
    """
    Creating host entry in local ssh config with name ssh-forever
    """
      And the output should contain:
    """
    Next: check for a public key.
    You do not appear to have an identity file/public key. Expected one at
    """
      And the output should contain:
    """
    Would you like me to generate one? [Y/n]
    Fair enough, I'll be off then. You can generate your own by hand using

        ssh-keygen -t rsa

    """

  Scenario: Given an incorrectly protected identity file
    Given a file named "identity.file" with:
    """
    """
      And I run `ssh-forever hedge@localhost --debug --identity_file identity.file` interactively
     When I type "exit"
     Then the output should contain:
    """
    Copying your public key to the remote server.
    Prepare to enter your password for the last time...
    """
      And the output should contain:
    """
    Success. From now on you can just use plain old 'ssh'. Logging you in...
    """
      And the output should contain "Permissions 0644 for 'identity.file' are too open."
      And the output should contain "This private key will be ignored."

  Scenario: Given an incorrect identity file path
    Given a file named "identity.file" with:
    """
    """
     And I run `ssh-forever hedge@localhost --identity_file wrong/path/identity.file` interactively
    When I type "n"
     And the output should contain:
    """
    Would you like me to generate one? [Y/n]
    Fair enough, I'll be off then. You can generate your own by hand using

        ssh-keygen -t rsa

  """

  Scenario: Given an identity file path
   Given I run `ssh-forever hedge@localhost --identity_file identity.file` interactively
    When I type "Y"
     And I type "echo $SSH_CLIENT"
     And I type "echo $SSH_CONNECTION"
     And I type "exit"
    And the output should match /::1 (.*) 22/
    And the output should match /::1 (.*) ::1 22/

  Scenario: Given a config file path, identity file path and name
   Given I run `ssh-forever hedge@localhost --config_file config.file --identity_file identity.file --name test` interactively
    When I type "Y"
     And I type "echo $SSH_CLIENT"
     And I type "echo $SSH_CONNECTION"
     And I type "exit"
    Then the output should contain "You do not appear to have a config file. Expected one at"
    And the output should match /::1 (.*) 22/
    And the output should match /::1 (.*) ::1 22/

  Scenario: Given a config file path and name
   Given I run `ssh-forever hedge@localhost --config_file config.file --name test` interactively
    When I type "Y"
     And I type "echo $SSH_CLIENT"
     And I type "echo $SSH_CONNECTION"
     And I type "exit"
    Then the output should contain "You do not appear to have a config file. Expected one at"
    And the output should match /::1 (.*) 22/
    And the output should match /::1 (.*) ::1 22/

  Scenario: Given a config file path, and quite
   Given I run `ssh-forever hedge@localhost --config_file config.file --quiet` interactively
    When I type "Y"
     And I type "echo $SSH_CLIENT"
     And I type "echo $SSH_CONNECTION"
     And I type "exit"
    And the output should match /\A::1 (.*) 22/
    And the output should match /::1 (.*) ::1 22\Z/
