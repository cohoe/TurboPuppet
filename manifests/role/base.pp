#
#
#
class role::base {
    # Platform base
    case $::osfamily {
        'windows': {
            # This is where we specify defaults that automatically apply to ALL
            # resources in child classes. These can be overridden as needed.
            Package {
                provider => chocolatey,
                ensure   => present
            }
            Exec {
                provider => powershell
            }

            # Any custom providers or whatnot that we just specified as
            # the defaults should probably have a profile setting them up.
            # @TODO someday this may need to be a generic profile::powershell
            include profile::packaging::chocolatey
            include profile::powershell::executionpolicy::unrestricted
        }
        default: {
            fail("platform is unsupported")
        }
    }
}