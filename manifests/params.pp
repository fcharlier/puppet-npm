class nodejs::params {
  $package_name = 'node-v0.6.12'
  $package_tar = "${package_name}.tar.gz"
  $package_path = "puppet:///modules/nodejs/${package_tar}"
  $home_path = '/home/node/opt'
  $ssl_lib_dev = $operatingsystem ? {
      debian => 'libssl-dev',
      ubuntu => 'libssl-dev',
      default => 'openssl-devel',
  }
  $gcc = $operatingsystem ? {
      debian => 'g++',
      ubuntu => 'g++',
      default => 'gcc-c++',
  }

  $libv8_dev = $operatingsystem ? {
      debian => "libv8-dev",
      ubuntu => "libv8-dev",
      default => "libv8-dev",
  }
}