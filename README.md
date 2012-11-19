# Puppet integrit module

Module for configuring [integrit](http://packages.debian.org/en/squeeze/integrit).

Tested on Debian GNU/Linux 6.0 Squeeze with Puppet 2.6. Patches for other
operating systems welcome.

## Usage

```puppet
class { 'integrit':
  config  => '/etc/integrit/integrit.conf',
  known   => '/var/lib/integrit/known.cdb',
  current => '/var/lib/integrit/current.cdb',
  ignore  => [
    '/dev', '/sys', '/home', '/proc', '/tmp', '/var', 
    '/root', '/usr/local','/usr/src', '/lost+found'
  ],
}
```

