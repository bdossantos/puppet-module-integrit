class integrit(
  $config = '/etc/integrit/integrit.conf',
  $root = '/',
  $known = '/var/lib/integrit/known.cdb',
  $current = '/var/lib/integrit/current.cdb',
  $log = '/var/log/integrit.log',
  $ignore = [
    '/dev', '/sys', '/home', '/proc', '/tmp', '/var', '/root', '/usr/local',
    '/usr/src', '/lost+found', '/nas'
  ]
) {

  package { 'integrit':
    ensure  => 'installed',
    notify  => Exec['initialization'],
  }

  File {
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    require => Package['integrit'],
  }

  file { $integrit::config:
    ensure  => file,
    content => template('integrit/integrit.conf.erb'),
  }

  file { '/etc/cron.daily/integrit':
    ensure  => absent,
  }

  Exec {
    refreshonly => true,
    require     => Package['integrit'],
    path        => '/bin/:/usr/bin/:/usr/sbin/',
  }

  exec { 'initialization':
    command   => "nice -n 19 ionice -c 3 \
                  integrit -C ${integrit::config} -u -q && \
                  mv ${integrit::current} ${integrit::known}",
    subscribe => File[$integrit::config],
    notify    => Exec['check_integrity'],
  }

  exec { 'check_integrity':
    command => "nohup nice -n 19 \
                integrit -C ${integrit::config} -c -q &> ${integrit::log} &",
  }

  $logger = "/usr/bin/logger -t integrit -f ${integrit::log}"

  cron { 'integrit':
    command => "nice -n 19 ionice -c 3 integrit -C ${integrit::config} -c &> ${integrit::log} || ${logger}",
    user    => 'root',
    hour    => fqdn_rand(6),
    minute  => fqdn_rand(59),
    require => Package['integrit'],
  }
}