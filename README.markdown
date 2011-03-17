# ssh-forever

Simple command to give you password-less SSH login on remote servers:

    ssh-forever username@yourserver.com [options]
    
    see `ssh-forever --help` for details on the options availlable.

## Installation

    gem sources --add http://gemcutter.org
    sudo gem install ssh-forever

## Example:

    [matt@bowie ssh-forever (master)]$ ssh-forever mattwynne@mattwynne.net -n dreamhost
    You do not appear to have a public key. I expected to find one at /Users/matt/.ssh/id_rsa.pub
    Would you like me to generate one? [Y/n]y
    Copying your public key to the remote server. Prepare to enter your password for the last time.
    mattwynne@mattwynne.net's password:
    Success. From now on you can just use plain old 'ssh'. Logging you in...
    Linux broncos 2.6.29-xeon-aufs2.29-ipv6-qos-grsec #1 SMP Thu Jul 9 16:42:58 PDT 2009 x86_64
      _
     | |__ _ _ ___ _ _  __ ___ ___
     | '_ \ '_/ _ \ ' \/ _/ _ (_-<
     |_.__/_| \___/_||_\__\___/__/

     Welcome to broncos.dreamhost.com

    Any malicious and/or unauthorized activity is strictly forbidden.
    All activity may be logged by DreamHost Web Hosting.

    Last login: Sat Aug 15 17:24:17 2009
    [broncos]$ exit
    [matt@bowie ssh-forever (master)]$ ssh dreamhost

## Why?

Because I can never remember how to do it by hand. Now I don't have to, and nor do you.

## Copyright

Copyright (c) 2009 Matt Wynne. See LICENSE for details.

## Disclaimer

This is open source. If you're worried, read the code before you run it. Don't come crying to me if it fucks something up for you.