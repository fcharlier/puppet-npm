class nodejs::params {
  $package_name = 'node-v0.8.2'
  $package_tar = "${package_name}.tar.gz"
  $package_path = "puppet:///modules/nodejs/${package_tar}"
  $home_path = '/usr/local'
}
