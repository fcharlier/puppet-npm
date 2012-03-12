# Class: nodesjs
#
# Description:
#  Ensure all needed install tools are availeable and install nodejs from source
#
# Usage:
# `include nodejs`
class nodejs {
  require nodejs::params

  user { "node":
      ensure => "present",
      home => "/home/node",
  }

  package { "openssl":
      ensure => "installed",
  }

  package { "ssl_dev":
      name => "${nodejs::params::ssl_lib_dev}",
      ensure => "installed",
  }

  package { "node_gcc":
      name => "${nodejs::params::gcc}",
      ensure => "installed",
  }

  file { "/home/node":
      ensure => "directory",
      owner => "node",
  }

  file { "node_path":
      path => "${nodejs::params::home_path}",
      ensure => "directory",
      require => File["/home/node"],
      owner => "node",
  }

  file { "/home/node/.bashrc":
      ensure => "present",
      owner => "node",
      content => template('nodejs/node_bashrc.erb')
  }

  file { "/tmp/node_tar":
      path => "${nodejs::params::package_tar}",
      source => "${nodejs::params::package_path}",
      ensure => "present",
      owner => "node",
      group => "node",
  }

  exec { "extract_node":
      command => "tar -xzf ${nodejs::params::package_tar}",
      cwd => "/tmp",
      path => ["/usr/bin", "/usr/sbin", "/bin"],
      creates => "/tmp/{$nodejs::params::package_name}",
      require => [File["/tmp/node_tar"], User["node"]],
      user => "node",
  }

  exec { "bash ./configure --prefix=${nodejs::params::home_path}":
      alias => "configure_node",
      cwd => "/tmp/${nodejs::params::package_name}",
      path => ["/usr/bin", "/usr/sbin", "/bin"],
      require => [Exec["extract_node"], Package["openssl"], Package["ssl__dev"], Package["node_gcc"]],
      timeout => 0,
      creates => "/tmp/$nodejs::params::package_name/.lock-wscript",
      user => "node",
  }

  file { "/tmp/node_package":
      path => "${nodejs::params::package_name}",
      ensure => "directory",
      owner => "node",
      group => "node",
      require => Exec["configure_node"]
  }

  exec { "make_node":
      command => "make",
      cwd => "/tmp/${nodejs::params::package_name}",
      path => ["/usr/bin", "/usr/sbin", "/bin"],
      require => Exec["configure_node"],
      timeout => 0,
      user => "node",
  }

  exec { "install_node":
      command => "make install",
      cwd => "/tmp/${nodejs::params::package_name}",
      require => Exec["make_node"],
      path => ["/usr/bin", "/usr/sbin", "/bin"],
      timeout => 0,
      creates => "${nodejs::params::home_path}/bin/node",
      user => "node",
  }

  file { "/node/bin/node":
      path => "${nodejs::params::home_path}",
      owner => "node",
      group => "node",
      require => Exec["install_node"],
      recurse => true
  }

  file { "/node/bin/node-waf":
      path => "${nodejs::params::home_path}",
      owner => "node",
      group => "node",
      recurse => true,
          require => Exec["install_node"]
  }

}