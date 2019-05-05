#
# Git
#
class profile::tool::git {
    package { 'git': }

    case $::kernel {
        'windows': {
            package { 'github-desktop':
                notify => Exec['kill github-desktop app']
            }

            # Github Desktop assumes that you instantly want to log in
            # when you install. We don't. Go away.
            exec { 'kill github-desktop app':
                command     => 'Sleep 15; Stop-Process -ProcessName GithubDesktop',
                refreshonly => true
            }
        }
        'Linux': {
            package { 'gitkraken':
                require => Yumrepo['_copr_elken-gitkraken']
            }

            # There's a thing where it's linked against a filename that doesn't exist.
            # But the library does. Whatevs.....
            file { '/usr/lib64/libcurl-gnutls.so.4':
                ensure  => link,
                target  => '/usr/lib64/libcurl.so.4',
                require => Package['gitkraken']
            }
        }
        default: { }
    }
}