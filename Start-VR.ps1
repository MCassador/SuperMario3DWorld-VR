<#
    Super Mario 3D World VR - session start script (Windows x64, PowerShell 5.1)

    Started by Start-VR.cmd. One VR session, then everything Cemu-side is put
    back. In order, it

      * finds Cemu.exe (asked once, remembered in cemu-path.txt beside this file),
      * uses the Cemu data folder that Cemu itself would use - the portable
        folder if one exists next to Cemu.exe, otherwise %APPDATA%\Cemu, so you
        never have to create a portable installation,
      * copies the graphic packs into that folder's graphicPacks directory,
      * backs up settings.xml, enables the packs for the chosen mode and
        selects Vulkan,
      * starts Cemu with the VR layer enabled for that one process,
      * after you quit Cemu switches those packs off again (unless you asked
        otherwise) and restores the graphics API.

    Start-VR.cmd starts in Diorama. R3 switches camera mode in gameplay.
    Only the combined stereo pack is enabled; legacy separate packs are disabled.

    Cemu settings and packs are stored in its data folder; launcher preferences
    are stored beside this script. No system-wide layer is installed.
#>

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$packs = @('Mario3DWorld_VR', 'Mario3DWorld_FPS')
$legacyPacks = @('Mario3DWorld_VR_FirstPerson')
$defaultPreset = '120 FPS (60 Hz gameplay)'
$stereoPack = 'Mario3DWorld_VR'
$modeName = 'Diorama / First Person (R3)'

function Say([string] $text) { Write-Host $text }

function Fail([string] $text) {
    Write-Host ''
    Write-Host ('Stopped: ' + $text)
    Write-Host ''
    exit 1
}

function EnsureNode($parent, [string] $name, $document) {
    $node = $parent.SelectSingleNode($name)
    if (-not $node) { $node = $parent.AppendChild($document.CreateElement($name)) }
    return $node
}

function IsOurEntry($entry) {
    $file = $entry.GetAttribute('filename')
    foreach ($pack in ($packs + $legacyPacks)) {
        if ($file -match ('(^|[\\/])' + [regex]::Escape($pack) + '[\\/]rules\.txt$')) { return $true }
    }
    return $false
}

# Community graphic packs that change the picture in ways the VR session
# does not want. Each one is switched to a safe preset for the session and the
# preset chosen in Cemu is put back afterwards (a choice made during the
# session stays). The environment variable named in Keep, set to 1, leaves that
# pack alone.
#  - Shadow Resolution multiplies the game's shadow map; the VR layer can draw it
#    once per eye, and a multiplied map is the likeliest thing to make that unstable.
#  - Contrasty replaces the game's final composite shader with a colour grade.
#    Its "High Contrasty" and "Neutral Contrasty" presets brighten the picture
#    (gamma above 1, exposure above 1), which is much stronger in a headset;
#    its "Default" preset is neutral.
$sessionPresets = @(
    @{ Label = 'Shadows  '; Match = 'SuperMario3DWorld_Shadows[\\/]rules\.txt$';  Safe = 'Medium (100%, Default)'; Keep = 'VR_KEEP_SHADOW_PRESET' },
    @{ Label = 'Contrasty'; Match = 'SuperMario3DWorld_Contrasty[\\/]rules\.txt$'; Safe = 'Default';                Keep = 'VR_KEEP_CONTRAST_PRESET' }
)

function LowerSessionPresets($graphicPack) {
    $saved = @{}
    foreach ($entry in @($graphicPack.SelectNodes('Entry'))) {
        $file = $entry.GetAttribute('filename')
        foreach ($rule in $sessionPresets) {
            if ($file -notmatch $rule.Match) { continue }
            if ([Environment]::GetEnvironmentVariable($rule.Keep) -eq '1') { continue }
            $node = $entry.SelectSingleNode('Preset/preset')
            if ($node -and $node.InnerText -and $node.InnerText -ne $rule.Safe) {
                $saved[$file] = @{ Old = $node.InnerText; Safe = $rule.Safe; Label = $rule.Label }
                $node.InnerText = $rule.Safe
            }
        }
    }
    return $saved
}

function RestoreSessionPresets($graphicPack, $saved) {
    $restored = $false
    foreach ($entry in @($graphicPack.SelectNodes('Entry'))) {
        $file = $entry.GetAttribute('filename')
        if (-not $saved.ContainsKey($file)) { continue }
        $node = $entry.SelectSingleNode('Preset/preset')
        # Only while it is still what this script set.
        if ($node -and $node.InnerText -eq $saved[$file].Safe) {
            $node.InnerText = $saved[$file].Old
            $restored = $true
        }
    }
    return $restored
}

# What the launcher changes in settings.xml is written to this file before the
# change and removed after a clean tidy-up. If it is still there at the next
# start, the last session was cut short (window closed, process killed), so the
# original values are put back first instead of being read as the original.
$stateFile = Join-Path $root 'session-state.json'

function RecoverPreviousSession($stateFile, $settingsFile) {
    try { $state = Get-Content -LiteralPath $stateFile -Raw | ConvertFrom-Json }
    catch { Remove-Item -LiteralPath $stateFile -Force -ErrorAction SilentlyContinue; return }
    if (-not $state -or $state.settings -ne $settingsFile) { return }
    $xml = New-Object System.Xml.XmlDocument
    $xml.PreserveWhitespace = $true
    $xml.Load($settingsFile)
    $content = $xml.DocumentElement
    $graphicPack = $content.SelectSingleNode('GraphicPack')
    if ($graphicPack) {
        foreach ($entry in @($graphicPack.SelectNodes('Entry'))) {
            if (IsOurEntry $entry) { [void] $graphicPack.RemoveChild($entry) }
        }
        foreach ($item in @($state.presets)) {
            if (-not $item) { continue }
            foreach ($entry in @($graphicPack.SelectNodes('Entry'))) {
                if ($entry.GetAttribute('filename') -ne $item.file) { continue }
                $node = $entry.SelectSingleNode('Preset/preset')
                if ($node -and $node.InnerText -eq $item.safe) { $node.InnerText = $item.old }
            }
        }
    }
    if ($state.api -and $state.api -ne '1') {
        $api = $content.SelectSingleNode('Graphic/api')
        if ($api) { $api.InnerText = $state.api }
    }
    foreach ($name in @('logflag', 'advanced_ppc_logging')) {
        $node = $content.SelectSingleNode($name)
        $value = $state.$name
        if ($null -eq $value) {
            if ($node) { [void] $content.RemoveChild($node) }
        } else {
            if (-not $node) { $node = $content.AppendChild($xml.CreateElement($name)) }
            $node.InnerText = [string] $value
        }
    }
    $xml.Save($settingsFile)
    Remove-Item -LiteralPath $stateFile -Force
    Write-Host 'The last session did not finish cleaning up; your Cemu settings were put back first.'
}

Say ''
$versionFile = Join-Path $root 'VERSION'
$version = 'Alpha'
if (Test-Path -LiteralPath $versionFile) { $version = (Get-Content -LiteralPath $versionFile -Raw).Trim() }
Say ('Super Mario 3D World VR - ' + $version + ' - ' + $modeName)
Say '-------------------------------------'

# --- the package itself -----------------------------------------------------
$layer = Join-Path $root 'layer'
foreach ($needed in @((Join-Path $layer 'cemuvr_layer.dll'), (Join-Path $layer 'VK_LAYER_CEMUVR_core.json'))) {
    if (Test-Path -LiteralPath $needed) { continue }
    $hint = ''
    if (Test-Path -LiteralPath (Join-Path $root 'core')) {
        $hint = [Environment]::NewLine +
                '       This looks like the source folder. Use the installation ZIP instead:' +
                [Environment]::NewLine +
                '       it is the one that contains layer\cemuvr_layer.dll.'
    }
    Fail ('The package is incomplete, missing: ' + $needed + $hint)
}

# --- where is Cemu? ---------------------------------------------------------
$pathFile = Join-Path $root 'cemu-path.txt'
$cemuExe = $null
if (Test-Path -LiteralPath $pathFile) {
    $remembered = (Get-Content -LiteralPath $pathFile -Raw).Trim()
    if ($remembered -and (Test-Path -LiteralPath $remembered)) { $cemuExe = $remembered }
}
if (-not $cemuExe) {
    foreach ($guess in @((Join-Path (Split-Path -Parent $root) 'Cemu.exe'), (Join-Path $root 'Cemu.exe'))) {
        if (Test-Path -LiteralPath $guess) { $cemuExe = $guess; break }
    }
}
if (-not $cemuExe) {
    Say 'This folder is meant to sit in your Cemu folder, next to Cemu.exe.'
    Say 'It does not, so please point me at Cemu.exe once (a file dialog opens).'
    try {
        Add-Type -AssemblyName System.Windows.Forms
        $dialog = New-Object System.Windows.Forms.OpenFileDialog
        $dialog.Title = 'Select Cemu.exe'
        $dialog.Filter = 'Cemu (Cemu.exe)|Cemu.exe|All files (*.*)|*.*'
        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $cemuExe = $dialog.FileName }
    } catch {
        $cemuExe = (Read-Host 'Full path to Cemu.exe').Trim('"')
    }
}
if (-not $cemuExe -or -not (Test-Path -LiteralPath $cemuExe)) { Fail 'No Cemu.exe selected.' }
Set-Content -LiteralPath $pathFile -Value $cemuExe -Encoding UTF8
$cemuDir = Split-Path -Parent $cemuExe

if (Get-Process -Name 'Cemu' -ErrorAction SilentlyContinue) {
    Fail 'Cemu is already running. Close it and start this file again.'
}

# --- the folder Cemu keeps its data in --------------------------------------
$portable = Join-Path $cemuDir 'portable'
if (Test-Path -LiteralPath $portable) { $data = $portable } else { $data = Join-Path $env:APPDATA 'Cemu' }
$settingsFile = Join-Path $data 'settings.xml'
if (-not (Test-Path -LiteralPath $settingsFile)) {
    Fail ('Cemu has no settings here yet: ' + $settingsFile + [Environment]::NewLine +
          '       Start Cemu once, set up your game and gamepad, close Cemu, then run this file again.')
}
Say ('Cemu:     ' + $cemuExe)
Say ('Settings: ' + $settingsFile)
if (Test-Path -LiteralPath $stateFile) { RecoverPreviousSession $stateFile $settingsFile }

# --- graphic packs ----------------------------------------------------------
$packRoot = Join-Path $data 'graphicPacks'
New-Item -ItemType Directory -Path $packRoot -Force | Out-Null
foreach ($pack in $packs) {
    $source = Join-Path $root (Join-Path 'graphicPacks' $pack)
    if (-not (Test-Path -LiteralPath $source)) { Fail ('The package is incomplete, missing: ' + $source) }
    $target = Join-Path $packRoot $pack
    $parentPath = [IO.Path]::GetFullPath((Split-Path -Parent $target)).TrimEnd('\')
    if ($parentPath -ne [IO.Path]::GetFullPath($packRoot).TrimEnd('\')) { Fail 'Invalid pack destination.' }
    if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force }
    Copy-Item -LiteralPath $source -Destination $target -Recurse -Force
}
Say ('Packs:    copied into ' + $packRoot)

# The glove orientation presets calibrated last time (with the grip + Minus chords) are put back into
# the copy of the patch: Watch-Perf.ps1 saves them to hand-presets.txt while the game runs.
$handPresetFile = Join-Path $root 'hand-presets.txt'
if (Test-Path -LiteralPath $handPresetFile) {
    try {
        $patchCopy = Join-Path $packRoot 'Mario3DWorld_VR\patch_vr.asm'
        $savedPresets = [IO.File]::ReadAllText($handPresetFile)
        $patchText = [IO.File]::ReadAllText($patchCopy)
        $restored = @()
        foreach ($match in [regex]::Matches($savedPresets, '(ML|MR|PL|PR)=(\d+)')) {
            $value = [int] $match.Groups[2].Value
            if ($value -lt 0 -or $value -gt 23) { continue }
            $tag = $match.Groups[1].Value
            $patchText = [regex]::Replace($patchText, ('\.int \d+( ; @HP_' + $tag + ')'), ('.int ' + $value + '$1'))
            $restored += ($tag + '=' + $value)
        }
        [IO.File]::WriteAllText($patchCopy, $patchText, (New-Object System.Text.UTF8Encoding($false)))
        if ($restored.Count -gt 0) { Say ('Gloves:   orientation presets from last time: ' + ($restored -join ' ')) }
    } catch {
        Say ('Could not restore the glove presets: ' + $_.Exception.Message)
    }
}

# The camera-behind-Mario distance chosen last time with the right stick (Watch-Perf.ps1 saves it
# to camera-distance.txt) is put back into the copy of the patch.
$cameraFile = Join-Path $root 'camera-distance.txt'
if (Test-Path -LiteralPath $cameraFile) {
    try {
        $patchCopy = Join-Path $packRoot 'Mario3DWorld_VR\patch_vr.asm'
        $savedDist = [double]::Parse(([IO.File]::ReadAllText($cameraFile)).Trim(), [Globalization.CultureInfo]::InvariantCulture)
        if ($savedDist -ge 80 -and $savedDist -le 600) {
            $bits = [BitConverter]::ToUInt32([BitConverter]::GetBytes([single] $savedDist), 0)
            $patchText = [IO.File]::ReadAllText($patchCopy)
            $patchText = [regex]::Replace($patchText, '\.int 0x[0-9A-Fa-f]+( ; @CAM_DIST)', ('.int 0x' + $bits.ToString('X8') + '$1'))
            [IO.File]::WriteAllText($patchCopy, $patchText, (New-Object System.Text.UTF8Encoding($false)))
            Say ('Camera:   behind-Mario distance from last time: ' + [string]::Format([Globalization.CultureInfo]::InvariantCulture, '{0:F0}', $savedDist))
        }
    } catch {
        Say ('Could not restore the camera distance: ' + $_.Exception.Message)
    }
}

# The first-person pull-back chosen last time (fp-distance.txt, saved by Watch-Perf.ps1) likewise.
$fpFile = Join-Path $root 'fp-distance.txt'
if (Test-Path -LiteralPath $fpFile) {
    try {
        $patchCopy = Join-Path $packRoot 'Mario3DWorld_VR\patch_vr.asm'
        $savedFp = [double]::Parse(([IO.File]::ReadAllText($fpFile)).Trim(), [Globalization.CultureInfo]::InvariantCulture)
        if ($savedFp -ge 0 -and $savedFp -le 600) {
            $bits = [BitConverter]::ToUInt32([BitConverter]::GetBytes([single] $savedFp), 0)
            $patchText = [IO.File]::ReadAllText($patchCopy)
            $patchText = [regex]::Replace($patchText, '\.int 0x[0-9A-Fa-f]+( ; @FP_DIST)', ('.int 0x' + $bits.ToString('X8') + '$1'))
            [IO.File]::WriteAllText($patchCopy, $patchText, (New-Object System.Text.UTF8Encoding($false)))
            Say ('Camera:   first-person pull-back from last time: ' + [string]::Format([Globalization.CultureInfo]::InvariantCulture, '{0:F0}', $savedFp))
        }
    } catch {
        Say ('Could not restore the first-person pull-back: ' + $_.Exception.Message)
    }
}

# --- settings: backup, enable packs, Vulkan ---------------------------------
$backupDir = Join-Path $data 'Mario3DWorld-VR-backups'
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
$backup = Join-Path $backupDir ('settings-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.xml')
Copy-Item -LiteralPath $settingsFile -Destination $backup
Get-ChildItem -LiteralPath $backupDir -Filter 'settings-*.xml' | Sort-Object Name -Descending |
    Select-Object -Skip 5 | Remove-Item -Force -ErrorAction SilentlyContinue

$presetFile = Join-Path $root 'fps-preset.txt'
$preset = $defaultPreset
if (Test-Path -LiteralPath $presetFile) {
    $remembered = (Get-Content -LiteralPath $presetFile -Raw).Trim()
    if ($remembered) { $preset = $remembered }
}

$vrPresetFile = Join-Path $root 'vr-preset.txt'
$vrPreset = $null
if (Test-Path -LiteralPath $vrPresetFile) {
    $remembered = (Get-Content -LiteralPath $vrPresetFile -Raw).Trim()
    if ($remembered) { $vrPreset = $remembered }
}

$xml = New-Object System.Xml.XmlDocument
$xml.PreserveWhitespace = $true
$xml.Load($settingsFile)
$content = $xml.DocumentElement

$previousLogging = @{}
foreach ($name in @('logflag', 'advanced_ppc_logging')) {
    $node = $content.SelectSingleNode($name)
    $previousLogging[$name] = if ($node) { $node.InnerText } else { $null }
    $node = EnsureNode $content $name $xml
    $node.InnerText = if ($name -eq 'logflag') { '0' } else { 'false' }
}

$graphic = EnsureNode $content 'Graphic' $xml
$api = EnsureNode $graphic 'api' $xml
$previousApi = $api.InnerText
if ($previousApi -ne '1') {
    $api.InnerText = '1'
    Say ('Graphics: switched to Vulkan for this session (was ' + $previousApi + ').')
}

$graphicPack = EnsureNode $content 'GraphicPack' $xml
foreach ($entry in @($graphicPack.SelectNodes('Entry'))) {
    if (IsOurEntry $entry) { [void] $graphicPack.RemoveChild($entry) }
}
$presetsSaved = LowerSessionPresets $graphicPack
foreach ($file in $presetsSaved.Keys) {
    $item = $presetsSaved[$file]
    Say ($item.Label + ': ' + $item.Old + ' -> ' + $item.Safe + ' for this session')
}
$vrEntry = $xml.CreateElement('Entry')
$vrEntry.SetAttribute('filename', 'graphicPacks/' + $stereoPack + '/rules.txt')
if ($vrPreset) {
    $vrGroup = $xml.CreateElement('Preset')
    $vrName = $xml.CreateElement('preset')
    $vrName.InnerText = $vrPreset
    [void] $vrGroup.AppendChild($vrName)
    [void] $vrEntry.AppendChild($vrGroup)
}
[void] $graphicPack.AppendChild($vrEntry)
$fpsEntry = $xml.CreateElement('Entry')
$fpsEntry.SetAttribute('filename', 'graphicPacks/Mario3DWorld_FPS/rules.txt')
$presetGroup = $xml.CreateElement('Preset')
$presetName = $xml.CreateElement('preset')
$presetName.InnerText = $preset
[void] $presetGroup.AppendChild($presetName)
[void] $fpsEntry.AppendChild($presetGroup)
[void] $graphicPack.AppendChild($fpsEntry)
$state = @{
    settings = $settingsFile
    api = $previousApi
    logflag = $previousLogging['logflag']
    advanced_ppc_logging = $previousLogging['advanced_ppc_logging']
    presets = @($presetsSaved.Keys | ForEach-Object { @{ file = $_; old = $presetsSaved[$_].Old; safe = $presetsSaved[$_].Safe } })
}
ConvertTo-Json -InputObject $state -Depth 4 | Set-Content -LiteralPath $stateFile -Encoding UTF8
$xml.Save($settingsFile)
Say ('Enabled:  Super Mario 3D World VR ' + $modeName + ' + FPS Unlock (' + $preset + ')')
Say ('Backup:   ' + $backup)

# --- run --------------------------------------------------------------------
$env:VK_LAYER_PATH = $layer
$env:VK_INSTANCE_LAYERS = 'VK_LAYER_CEMUVR_core'
$env:VK_LOADER_LAYERS_ENABLE = 'VK_LAYER_CEMUVR_core'
$env:CEMUVR_ENABLE = '1'
# Both camera modes derive their eye translations from the same pose mailbox.
$env:CEMUVR_MARIO_WORLD_SIZE = '2'
# Other implicit Vulkan layers - another Cemu VR layer such as BetterVR, or a
# screen overlay - would fight over the same frames. They are switched off for
# this one process only; that is the tested configuration.
if ($env:VR_KEEP_OTHER_LAYERS -ne '1') { $env:VK_LOADER_LAYERS_DISABLE = '~implicit~' }

Say ''
Say 'Starting Cemu with the VR layer. Put the headset on.'
Say 'Starts in Diorama. Click R3 in a level to switch to First Person and back.'
Say 'This window stays open until you quit Cemu, then it tidies up.'
Say ''
$sessionStart = Get-Date
$cemu = $null
$perfCsv = $null
$diagTxt = $null
try {
    $cemu = Start-Process -FilePath $cemuExe -WorkingDirectory $cemuDir -PassThru
    # A small helper counts rendered frames and gameplay steps once a second (see Watch-Perf.ps1)
    # so a slow-running game shows up in the summary printed below. It only reads.
    $sampler = Join-Path $root 'Watch-Perf.ps1'
    $perfCsv = Join-Path $env:TEMP ('cemuvr-perf-' + $cemu.Id + '.csv')
    $diagTxt = Join-Path $env:TEMP ('cemuvr-diag-' + $cemu.Id + '.txt')
    if (Test-Path -LiteralPath $sampler) {
        try {
            $samplerArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', ('"' + $sampler + '"'),
                             '-CemuPid', [string] $cemu.Id, '-Out', ('"' + $perfCsv + '"'),
                             '-PresetFile', ('"' + $handPresetFile + '"'), '-DiagOut', ('"' + $diagTxt + '"'), '-CameraFile', ('"' + $cameraFile + '"'), '-FpFile', ('"' + $fpFile + '"'))
            [void] (Start-Process -FilePath 'powershell.exe' -ArgumentList $samplerArgs -WindowStyle Hidden -PassThru)
        } catch { $perfCsv = $null }
    } else { $perfCsv = $null }
    $cemu.WaitForExit()
} catch {
    Say ('Could not start Cemu: ' + $_.Exception.Message)
}

# --- keep what this session left behind --------------------------------------
# Cemu overwrites its log.txt and the VR layer overwrites cemuvr_layer.log on the
# next start, so a crash would leave nothing to look at. Both are copied here,
# together with how long Cemu ran and the code it exited with (0 = a normal quit).
$sessionExit = $null
try {
    if ($cemu) {
        try { $sessionExit = $cemu.ExitCode } catch { $sessionExit = $null }
        $ranFor = [int] ((Get-Date) - $sessionStart).TotalSeconds
        $stamp = $sessionStart.ToString('yyyyMMdd-HHmmss')
        $logDir = Join-Path $root 'session-logs'
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        if ($null -ne $sessionExit) { $codeText = ('0x{0:X8} ({0})' -f $sessionExit) } else { $codeText = 'unknown' }
        $summary = @(
            ('Started:    ' + $sessionStart.ToString('s')),
            ('Ran for:    ' + $ranFor + ' s'),
            ('Exit code:  ' + $codeText),
            ('FPS preset: ' + $preset),
            ('VR preset:  ' + $vrPreset)
        )
        Set-Content -LiteralPath (Join-Path $logDir ($stamp + '-session.txt')) -Value $summary -Encoding UTF8
        $sources = @(
            @{ From = (Join-Path $data 'log.txt'); Suffix = '-cemu-log.txt' },
            @{ From = (Join-Path $cemuDir 'cemuvr_layer.log'); Suffix = '-layer.log' }
        )
        foreach ($item in $sources) {
            if ((Test-Path -LiteralPath $item.From) -and ((Get-Item -LiteralPath $item.From).Length -gt 0)) {
                Copy-Item -LiteralPath $item.From -Destination (Join-Path $logDir ($stamp + $item.Suffix)) -Force
            }
        }
        Get-ChildItem -LiteralPath $logDir -File | Sort-Object LastWriteTime -Descending |
            Select-Object -Skip 36 | Remove-Item -Force -ErrorAction SilentlyContinue
        Say ('Session:   Cemu ran ' + $ranFor + ' s, exit code ' + $codeText)
        if ($perfCsv -and (Test-Path -LiteralPath $perfCsv)) {
            Start-Sleep -Milliseconds 1500
            Copy-Item -LiteralPath $perfCsv -Destination (Join-Path $logDir ($stamp + '-perf.csv')) -Force
            $invariant = [Globalization.CultureInfo]::InvariantCulture
            $rows = @(Import-Csv -LiteralPath $perfCsv | Where-Object { [double]::Parse($_.steps_per_s, $invariant) -gt 10 })
            $tooSlow = $false
            foreach ($group in @(@{ Name = 'diorama       '; View = '0' }, @{ Name = 'first person  '; View = '1' }, @{ Name = 'all           '; View = '' })) {
                $mine = @($rows | Where-Object { $group.View -eq '' -or $_.view -eq $group.View })
                if ($mine.Count -lt 20) { continue }
                $fps = ($mine | ForEach-Object { [double]::Parse($_.frames_per_s, $invariant) } | Measure-Object -Average).Average
                $steps = ($mine | ForEach-Object { [double]::Parse($_.steps_per_s, $invariant) } | Measure-Object -Average).Average
                $slow = @($mine | Where-Object { [double]::Parse($_.steps_per_s, $invariant) -lt 55 }).Count
                Say ('Speed:     ' + $group.Name + ' ' + [string]::Format($invariant, '{0:F0} frames/s, gameplay {1:F0} of 60 steps/s, below 55 for {2:F0}% of the time', $fps, $steps, (100.0 * $slow / $mine.Count)))
                if ($steps -lt 55) { $tooSlow = $true }
            }
            if ($tooSlow) {
                Say '           The game itself ran slower than normal: the picture could not keep up.'
                Say '           Lower the Resolution graphic pack in Cemu (3840x2160 or 3200x1800) or use the 60 FPS preset.'
            }
            Remove-Item -LiteralPath $perfCsv -Force -ErrorAction SilentlyContinue
        }
        if ($diagTxt -and (Test-Path -LiteralPath $diagTxt)) {
            # what the fireball and blow counters showed (see Watch-Perf.ps1)
            Copy-Item -LiteralPath $diagTxt -Destination (Join-Path $logDir ($stamp + '-diag.txt')) -Force
            foreach ($diagLine in @(Get-Content -LiteralPath $diagTxt)) { Say $diagLine }
            Remove-Item -LiteralPath $diagTxt -Force -ErrorAction SilentlyContinue
        }
        if ($null -ne $sessionExit -and $sessionExit -ne 0) {
            Say 'Cemu did not end normally. The logs of this session are kept in:'
            Say ('           ' + $logDir)
        }
    }
} catch {
    Say ('Could not save the session logs: ' + $_.Exception.Message)
}

# --- put Cemu back the way it was -------------------------------------------
Start-Sleep -Milliseconds 500
$keep = ($env:VR_KEEP_PACKS -eq '1')
try {
    $xml = New-Object System.Xml.XmlDocument
    $xml.PreserveWhitespace = $true
    $xml.Load($settingsFile)
    $content = $xml.DocumentElement
    $changed = $false

    $graphicPack = $content.SelectSingleNode('GraphicPack')
    if ($graphicPack) {
        foreach ($entry in @($graphicPack.SelectNodes('Entry'))) {
            if (-not (IsOurEntry $entry)) { continue }
            if ($entry.GetAttribute('filename') -match 'Mario3DWorld_VR[\\/]rules\.txt$') {
                $chosenVr = $entry.SelectSingleNode('Preset/preset')
                if ($chosenVr -and $chosenVr.InnerText -and $chosenVr.InnerText -ne $vrPreset) {
                    Set-Content -LiteralPath $vrPresetFile -Value $chosenVr.InnerText -Encoding UTF8
                    Say ('Remembered your VR button preset: ' + $chosenVr.InnerText)
                }
            }
            if ($entry.GetAttribute('filename') -match 'Mario3DWorld_FPS') {
                $chosen = $entry.SelectSingleNode('Preset/preset')
                if ($chosen -and $chosen.InnerText -and $chosen.InnerText -ne $preset) {
                    Set-Content -LiteralPath $presetFile -Value $chosen.InnerText -Encoding UTF8
                    Say ('Remembered your FPS preset: ' + $chosen.InnerText)
                }
            }
            if (-not $keep) { [void] $graphicPack.RemoveChild($entry); $changed = $true }
        }
        if ($presetsSaved.Count -gt 0 -and -not $keep) {
            if (RestoreSessionPresets $graphicPack $presetsSaved) { $changed = $true }
        }
    }
    if ($previousApi -ne '1' -and -not $keep) {
        $graphic = $content.SelectSingleNode('Graphic')
        if ($graphic) {
            $api = $graphic.SelectSingleNode('api')
            if ($api) { $api.InnerText = $previousApi; $changed = $true }
        }
    }
    foreach ($name in @('logflag', 'advanced_ppc_logging')) {
        $node = $content.SelectSingleNode($name)
        if ($null -eq $previousLogging[$name]) {
            if ($node) { [void] $content.RemoveChild($node); $changed = $true }
        } else {
            $node = EnsureNode $content $name $xml
            $node.InnerText = $previousLogging[$name]
            $changed = $true
        }
    }
    if ($changed) { $xml.Save($settingsFile) }
    Remove-Item -LiteralPath $stateFile -Force -ErrorAction SilentlyContinue
} catch {
    Say ('Could not tidy up settings.xml: ' + $_.Exception.Message)
    Say ('A backup of the original file is here: ' + $backup)
    exit 1
}

Say ''
if ($keep) {
    Say 'Done. The VR packs stay switched on in Cemu (VR_KEEP_PACKS=1).'
} else {
    Say 'Done. The VR packs are switched off again, so ordinary 2D play is unaffected.'
}
Say ''
exit 0
