@slow
Feature: Help

  In order to ensure SSH-Forever is well defined
  As a developer of SSH-Forever
  I want to specify expected output

  Scenario: Run help command
    When I run `ssh-forever --help`
    Then the output should contain:
      """
      Usage: ssh-forever username@yourserver.com [options]

      More info:
        https://github.com/mattwynne/ssh-forever
          -b, --batch                      Run without interactive login
                                           Implies auto, intense, quiet and not login nor debug.
          -a, --auto                       Run without prompting.
          -c, --config_file [FILE]         SSH client config file path.
          -d, --debug                      Run SSH verbosely.
          -l, --login                      Open SSH connection and stay logged in (default).
          -p, --port [PORT]                SSH server port.
          -i, --identity_file [FILE]       SSH identity file path (no .pub extension).
          -j, --intense                    High SSH intensity.
                                           If no data from the server after 1 second (default 15): Disconnect after 1 (default 3) unanswered 'server-alive' message.
          -n, --name [NAME]                SSH host name alias you wish to use.
          -q, --quiet                      Run without output.
          -s, --strict                     SSH with stricthostkeychecking=yes (default:no)
      """

  Scenario Outline: Point to help when option is called incompletely
    When I run `ssh-forever --<option>`
    Then the output should contain:
    """
    Usage: ssh-forever username@yourserver.com [options]

    More info:
      https://github.com/mattwynne/ssh-forever
      ssh-forever --help

    """
  Examples:
    |option|
    |batch |
    |auto  |
    |login |
    |port  |
    |identity_file |
    |intense |
    |name |
    |quiet |
    |strict |
