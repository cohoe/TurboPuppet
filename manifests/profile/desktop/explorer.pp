#
# Tweaks to Explorer.exe
#
class profile::desktop::explorer {
    # We want to preserve the "RunAsAdministrator" bit.
    # https://stackoverflow.com/questions/28997799/how-to-create-a-run-as-administrator-shortcut-using-powershell
    file { "C:/Users/${turbosite::camper_username}/Desktop/sudo cmd.lnk":
        source => 'puppet:///modules/cfcc/sudocmd.lnk',
    }

    # Remove built-in shortcut files that are useless
    $junk_shortcuts = [
        "C:/Users/${turbosite::camper_username}/Desktop/Windows 10 Update Assistant.lnk",
        "C:/Users/Public/Desktop/3D Vision Photo Viewer.lnk"
    ]
    file { $junk_shortcuts: ensure => absent }

    # All edits need explorer.exe to reload before they take effect
    Hkcu {
        notify => Exec['Reload Explorer']
    }

    # Show file extensions
    hkcu { 'ShowFileExtensions':
        key   => 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        value => 'HideFileExt',
        data  => 0,
    }

    # Show Hidden Files
    hkcu { 'ShowHiddenFiles':
        key   => 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        value => 'Hidden',
        data  => 1,
    }

    # Remove search bar
    # https://www.askvg.com/how-to-remove-search-and-task-view-icons-from-windows-10-taskbar/
    hkcu { 'RemoveSearchBox':
        key   => 'Software\Microsoft\Windows\CurrentVersion\Search',
        value => 'SearchboxTaskbarMode',
        data  => 0,
    }

    # Remove taskbview button
    hkcu { 'RemoveTaskviewButton':
        key   => 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        value => 'ShowTaskViewButton',
        data  => 0,
    }

    # Remove People button
    hkcu { 'RemovePeopleButton':
        key   => 'Software\Policies\Microsoft\Windows\Explorer',
        value => 'HidePeopleBar',
        data  => 1,
    }

    # Remove the mail icon from the taskbar. This is surprisingly harder than it should be.
    hkcu { 'RemoveTaskbandFavorites':
        key   => 'Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband',
        value => 'Favorites',
        data  => 255,
    }

    # Show full path to files in the title and address bar
    hkcu { 'DisplayFullPath':
        key   => 'Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState',
        value => 'FullPath',
        data  => 1
    }

    # Expand to current folder in nav tree
    hkcu { 'ExpandCurrentNavTree':
        key   => 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
        value => 'NavPaneExpandToCurrentFolder',
        data  => 1,
    }

    # Add an Open with Notepad action to context menu of every file
    registry_key { 'OpenWithNotepadKey':
        path   => 'HKCR\*\shell\Open with Notepad',
        ensure => present,
        notify => Exec['Reload Explorer']
    }
    registry_key { 'OpenWithNotepadCommandKey':
        path   => 'HKCR\*\shell\Open with Notepad\command',
        ensure => present,
        notify => Exec['Reload Explorer']
    }
    registry::value { 'OpenWithNotepadCommandValue':
        key    => 'HKCR\*\shell\Open with Notepad\command',
        value  => '(default)',
        data   => 'notepad.exe %1',
        notify => Exec['Reload Explorer']
    }

    Registry_key['OpenWithNotepadKey']
    -> Registry_key['OpenWithNotepadCommandKey']
    -> Registry::Value['OpenWithNotepadCommandValue']

    exec { 'Reload Explorer':
        command     => "Stop-Process -ProcessName explorer",
        refreshonly => true,
    }
}