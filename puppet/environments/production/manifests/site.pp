node default {

  $default_packages   = [ 'vim', 'git', 'curl', 'wget', 'fontconfig' ]
  $default_npm_pkgs   = [ 'yo', 'bower', 'grunt-cli', 'phantomjs', 'generator-angular', 'generator-webapp' ]

  # exec { 'update':
  #   command     => 'yum upgrade -y && yum update -y',
  #   path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
  # }
  # ->
  package { $default_packages :
    ensure      => installed,
    before      => Class['nodejs'],
  }
  ->
  class { 'nodejs': 
    before      => Exec['update npm'],
  }
  ->
  package { 'n':
    ensure      => 'present',
    provider    => 'npm',
    require     => Class['nodejs'],
    before      => Exec['update node'],
  }
  ->
  exec { 'update node':
    command     => 'n stable',
    path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    require     => Package['n'],
    before      => Exec['update npm'],
  }
  ->
  exec { 'update npm':
    command     => 'npm install --global npm@latest',
    path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    require     => Exec['update node'],
  }
  ->
  package { $default_npm_pkgs :
    ensure      => 'present',
    provider    => 'npm',
    require     => Exec['update npm'],
    before      => Exec['update npm packages'],
  }
  ->
  exec { 'update npm packages':
    command     => 'npm update --global',
    path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
  }

  file { '/home/vagrant/workspace/src/Gruntfile.js':
    ensure      => 'present',
    noop        => 'true',
  }
  ->
  file_line { "update hostname in Gruntfile": 
    line        => '        hostname: \'0.0.0.0\',',
    path        => '/home/vagrant/workspace/src/Gruntfile.js', 
    match       => 'hostname: \'.*\',',
    ensure      => 'present',
    require     => File['/home/vagrant/workspace/src/Gruntfile.js'],
  }

  service { 'firewalld':
<<<<<<< HEAD
    enable      => false,
=======
>>>>>>> 7f437e9a3eb74e2f3fb64d60741ddcd04cf939c1
    ensure      => 'stopped',
  }

}
