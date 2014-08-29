# Class: apache::mod::auth_cas
#
# This class enables and configures Apache mod_auth_cas
# See: https://wiki.jasig.org/display/CASC/mod_auth_cas
#
# Parameters:
# - $cas_version              = '2',
# - $cas_debug                = 'Off',
# - $cas_cookie_path          = '/var/cache/mod_auth_cas/',
# - $cas_cookie_entropy       = '32',
# - $cas_cache_clean_interval = '1800',
# - $cas_login_url            = 'http://change_this',
# - $cas_validate_url         = 'http://change_this',
# - $cas_timeout              = '7200',
# - $cas_idle_timeout         = '3600',
# - $cas_validate_server      = 'On',
# - $cas_validate_depth       = '9',
# - $cas_allow_wildcard_cert  = 'Off',
# - $cas_certificate_path     = '/etc/ssl/certs/',
#
# Actions:
# - Enable and configure Apache mod_auth_cas
#
# Requires:
# - The apache class
#
# Sample Usage:
#
#  class { 'apache::mod::auth_cas':
#    cas_login_url    => 'https://login.somehost.edu/cas/login',
#    cas_validate_url => 'https://login.somehost.edu/cas/serviceValidate',
#  }

class apache::mod::auth_cas (
  $cas_version              = '2',
  $cas_debug                = 'Off',
  $cas_cookie_path          = '/var/cache/mod_auth_cas/',
  $cas_cookie_entropy       = '32',
  $cas_cache_clean_interval = '1800',
  $cas_login_url            = 'change_this',
  $cas_validate_url         = 'change_this',
  $cas_timeout              = '7200',
  $cas_idle_timeout         = '3600',
  $cas_validate_server      = 'On',
  $cas_validate_depth       = '9',
  $cas_allow_wildcard_cert  = 'Off',
  $cas_certificate_path     = '/etc/ssl/certs/',
){

  # validations
  validate_re($cas_debug, '^(On|Off)$', "${cas_debug} is not supported for cas_debug. Allowed values are 'On' and 'Off'.")
  validate_re($cas_validate_server, '^(On|Off)$', "${cas_validate_server} is not supported for cas_validate_server. Allowed values are 'On' and 'Off'.")
  validate_re($cas_allow_wildcard_cert, '^(On|Off)$', "${cas_allow_wildcard_cert} is not supported for cas_allow_wildcard_cert. Allowed values are 'On' and 'Off'.")
  validate_absolute_path($cas_cookie_path)
  validate_absolute_path($cas_certificate_path)
  unless is_integer($cas_version) {
      fail("${cas_version} is not supported for cas_version. Value must be an integer.")
  }
  unless is_integer($cas_cookie_entropy) {
      fail("${cas_cookie_entropy} is not supported for cas_cookie_entropy. Value must be an integer.")
  }
  unless is_integer($cas_cache_clean_interval) {
      fail("${cas_cache_clean_interval} is not supported for cas_cache_clean_interval. Value must be an integer.")
  }
  unless is_integer($cas_timeout) {
      fail("${cas_timeout} is not supported for cas_timeout. Value must be an integer.")
  }
  unless is_integer($cas_idle_timeout) {
      fail("${cas_idle_timeout} is not supported for cas_idle_timeout. Value must be an integer.")
  }
  unless is_integer($cas_validate_depth) {
      fail("${cas_validate_depth} is not supported for cas_validate_depth. Value must be an integer.")
  }

  ::apache::mod { 'auth_cas':
      package => 'mod_auth_cas',
  }

  file { $cas_cookie_path:
      ensure => directory,
      path   => $cas_cookie_path,
      owner  => $::apache::params::user,
      group  => $::apache::params::group,
      mode   => '0700',
  }

  # Template uses:
  # - $cas_version
  # - $cas_debug
  # - $cas_cookie_path
  # - $cas_cookie_entropy
  # - $cas_cache_clean_interval
  # - $cas_login_url
  # - $cas_validate_url
  # - $cas_proxy_validate_url
  # - $cas_timeout
  # - $cas_idle_timeout
  # - $cas_validate_server
  # - $cas_validate_depth
  # - $cas_allow_wildcard_cert
  # - $cas_certificate_path
  file {'auth_cas.conf':
    ensure  => file,
    path    => "${::apache::mod_dir}/auth_cas.conf",
    content => template('apache/mod/auth_cas.conf.erb'),
    require => [ Exec["mkdir ${::apache::mod_dir}"], File[$cas_cookie_path] ],
    before  => File[$::apache::mod_dir],
    notify  => Service['httpd']
  }
}

