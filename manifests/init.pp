# Class: nodesjs
#
# Description:
#  Ensure all needed install tools are availeable and install nodejs from source
#
# Usage:
# `include nodejs`
class nodejs {
  require nodejs::params

  package { "build-essential":
      ensure => "installed",
  }

  file { "/tmp/node_tar":
      path => "/tmp/${nodejs::params::package_tar}",
      source => "${nodejs::params::package_path}",
      ensure => "present",
  }

  exec { "extract_node":
      command => "tar -xzf ${nodejs::params::package_tar}",
      cwd => "/tmp",
      path => ["/usr/bin", "/usr/sbin", "/bin"],
      creates => "/tmp/${nodejs::params::package_name}",
      require => [File["/tmp/node_tar"]],
  }

  exec { "python ./configure --prefix=${nodejs::params::home_path}":
      alias => "configure_node",
      cwd => "/tmp/${nodejs::params::package_name}",
      path => ["/usr/bin", "/usr/sbin", "/bin"],
      require => [Exec["extract_node"], Package["build-essential"]],
      timeout => 0,
      creates => "/tmp/${nodejs::params::package_name}/.lock-wscript",
      logoutput => true,
  }

  file { "/tmp/node_package":
      path => "/tmp/${nodejs::params::package_name}",
      ensure => "directory",
      require => Exec["configure_node"]
  }

  exec { "make_node":
      command => "make",
      cwd => "/tmp/${nodejs::params::package_name}",
      path => ["/usr/bin", "/usr/sbin", "/bin"],
      require => Exec["configure_node"],
      timeout => 0,
      logoutput => true,
  }

  exec { "install_node":
      command => "make install",
      cwd => "/tmp/${nodejs::params::package_name}",
      require => Exec["make_node"],
      path => ["/usr/bin", "/usr/sbin", "/bin"],
      timeout => 0,
      logoutput => true,
  }

}
