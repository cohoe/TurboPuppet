#
# Camper user access profile.
#
class profile::access::camper {

    # In other places we key off of the $::kernel fact. That doesn't
    # work for us here since different distros have different groups.
    case $::osfamily {
        'windows': {
            include profile::access::uac::disable
            # $user_groups = ['BUILTIN\Administrators', "BUILTIN\Remote Management Users"]
            $user_groups = ['BUILTIN\Administrators']
        }
        'RedHat': {
            # camper : camper adm cdrom sudo dip plugdev lpadmin sambashare
            $user_groups = ['wheel']

            sudo::conf { 'camper':
                priority => 10,
                content  => "${turbosite::camper_username} ALL=(ALL) NOPASSWD: ALL"
            }
        }
        default: {
            fail("platform is unsupported")
        }
    }

    user { "${turbosite::camper_username}":
        ensure   => present,
        groups   => $user_groups,
        # password => "${turbosite::camper_username}",
        before   => Class['profile::access::autologin::enable']
    }

    include profile::access::autologin::enable
}
