#
# Minecraft
#
class profile::game::minecraft {
  # It's really funny that this is easier to install on Windows than Linux.
  case $::operatingsystem {
    'windows': {
      package { 'minecraft': }
    }
    'Fedora': {
      $minecraft_root = '/opt/minecraft'
      $minecraft_jar = 'Minecraft.jar'

      # Note the chained ordering here!
      file { 'MinecraftRoot':
        path   => $minecraft_root,
        ensure => directory,
      } ->
      file { 'MinecraftJar':
        path   => "${minecraft_root}/${minecraft_jar}",
        source => "puppet:///campfs/${minecraft_jar}",
      } ->
      file { 'MinecraftIcon':
        path   => "${minecraft_root}/icon.png",
        source => "puppet:///campfs/minecraft.png"
      } ->
      freedesktop::shortcut { 'Minecraft':
        exec       => "java -jar ${minecraft_root}/${minecraft_jar}",
        comment    => 'Minecraft',
        icon       => "${minecraft_root}/icon.png",
        categories => ['Games']
      } ->
      file { "${turbosite::camper_homedir}/Desktop/minecraft.desktop":
        source => 'file:///usr/local/share/applications/Minecraft.desktop',
        mode   => '0755',
        owner  => $turbosite::camper_username
      }
    }
    'Darwin': {
      package { 'minecraft': }
    }

    default: { fail('unsupported OS') }
  }

  # @TODO seed initial set of files so it doesnt go out to the internet
}
