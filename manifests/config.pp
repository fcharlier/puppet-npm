# Class: nodejs::config
#
# Description:
#  Holds some parameters for nodejs installation
#
# Usage:
# Should not called diretcly
class nodejs::config {
  $package_name = 'node-v0.6.12'
  $package_tar = '$package_name.tar.gz'
  $package_path = 'puppet:///modules/nodejs/$package_tar'
  $home_path = '/home/node/opt'
}