class sugarcrm::extract (
  $source_file    = 'SugarCE-6.5.16.zip',
  $extracted_name = 'SugarCE-Full-6.5.16',
  $dest_directory = '/var/www/html/',
  $apache_user    = 'apache',
  $apache_group   = 'apache',
) {
  
  package { 'zip':
    ensure => present,
  }

  file { "/var/tmp/${source_file}":
    ensure  => file,
    source  => "puppet:///modules/sugarcrm/${source_file}",
    owner   => root,
    group   => root,
  }

  # exec to extract the file from the zip
  # it uses -j to trash the 'archive' name, so just the contents
  # end up in $dest_directory

  exec { 'extract_sugarcrm':
    command => "/usr/bin/unzip -q /var/tmp/${source_file} -d ${dest_directory}",
    creates => "${dest_directory}/${extracted_name}/install.php",
    notify  => Exec['chown_sugarcrm'],
    require => [
      Package['zip'],
      File["/var/tmp/${source_file}"]
    ],
  }

  exec { 'chown_sugarcrm':
    command     => "/bin/chown -R ${apache_user}:${apache_group} ${dest_directory}/${extracted_name}/*",
    refreshonly => 'true',
  }

  # allows us to reference the 'live' version of sugar crm without having to track the extracted_name everywhere

  file { "${dest_directory}/active":
    ensure  => link,
    owner   => 'apache',
    group   => 'apache',
    target  => "${dest_directory}/${extracted_name}",
    require => Exec['extract_sugarcrm'],
  }
}
