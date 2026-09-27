<#
    Watch-Perf.ps1 - started by Start-VR.ps1 next to Cemu; you do not run it yourself.

    Once a second it reads two counters the FPS Unlock pack keeps in the game's
    memory (rendered frames and gameplay steps) and, if it can find it, which view
    is in use (0 = diorama, 1 = first person), and writes them to a .csv. The
    launcher prints a summary when Cemu closes: gameplay runs at 60 steps a second
    when all is well; fewer means the game itself is running slower than normal
    because the picture cannot keep up.

    With -DiagOut it also reads the small counter blocks of the VR pack (fireball
    and blow) and keeps a short text summary of them in that file, which the
    launcher prints and saves next to the other session logs.

    It only reads Cemu's memory (the ordinary Windows call for that) and writes
    nothing to it. If anything goes wrong it stops quietly and never affects Cemu.
#>
param(
    [Parameter(Mandatory = $true)] [int] $CemuPid,
    [Parameter(Mandatory = $true)] [string] $Out,
    [string] $PresetFile = '',
    [string] $DiagOut = '',
    [string] $CameraFile = '',
    [string] $FpFile = ''
)
$ErrorActionPreference = 'Stop'
$invariant = [Globalization.CultureInfo]::InvariantCulture

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class CvrMem {
    [StructLayout(LayoutKind.Sequential)]
    public struct MBI {
        public IntPtr BaseAddress; public IntPtr AllocationBase; public uint AllocationProtect;
        public ushort PartitionId; public IntPtr RegionSize; public uint State; public uint Protect; public uint Type;
    }
    [DllImport("kernel32.dll", SetLastError = true)] public static extern IntPtr OpenProcess(uint access, bool inherit, int pid);
    [DllImport("kernel32.dll")] public static extern bool CloseHandle(IntPtr h);
    [DllImport("kernel32.dll", SetLastError = true)] public static extern bool ReadProcessMemory(IntPtr h, IntPtr addr, byte[] buf, IntPtr size, out IntPtr read);
    [DllImport("kernel32.dll")] public static extern IntPtr VirtualQueryEx(IntPtr h, IntPtr addr, out MBI mbi, IntPtr len);
}
'@

function ReadBytes($handle, [long] $address, [int] $count) {
    $buffer = New-Object byte[] $count
    $got = [IntPtr]::Zero
    if (-not [CvrMem]::ReadProcessMemory($handle, [IntPtr] $address, $buffer, [IntPtr] $count, [ref] $got)) { return $null }
    if ([int64] $got -ne $count) { return $null }
    return , $buffer
}

function BigSingle([byte[]] $bytes, [int] $offset) {
    return [BitConverter]::ToSingle([byte[]] ($bytes[$offset + 3], $bytes[$offset + 2], $bytes[$offset + 1], $bytes[$offset]), 0)
}

function BigUInt32([byte[]] $bytes, [int] $offset) {
    return ([uint32] $bytes[$offset] * 16777216) + ([uint32] $bytes[$offset + 1] * 65536) + ([uint32] $bytes[$offset + 2] * 256) + [uint32] $bytes[$offset + 3]
}

$handle = [CvrMem]::OpenProcess(0x0410, $false, $CemuPid)   # PROCESS_VM_READ | PROCESS_QUERY_INFORMATION
if ($handle -eq [IntPtr]::Zero) { exit 0 }

try {
    $process = Get-Process -Id $CemuPid -ErrorAction Stop
    $mbi = New-Object CvrMem+MBI
    $mbiSize = [IntPtr] [Runtime.InteropServices.Marshal]::SizeOf($mbi)

    # The guest's code cave starts at guest address 0x01800000 and begins with the FPS pack's
    # counters ('MFPS', version 1). Wait for the game to start, then find that block.
    $telemetry = [long] 0
    $deadline = (Get-Date).AddMinutes(6)
    while ($telemetry -eq 0 -and (Get-Date) -lt $deadline -and -not $process.HasExited) {
        $address = [long] 0
        while ($address -lt 0x7FFFFFFF0000) {
            $size = [CvrMem]::VirtualQueryEx($handle, [IntPtr] $address, [ref] $mbi, $mbiSize)
            if ([int64] $size -eq 0) { break }
            $base = [int64] $mbi.BaseAddress
            $length = [int64] $mbi.RegionSize
            if ($length -le 0) { break }
            if ($mbi.State -eq 0x1000 -and $length -ge 0x400000 -and $length -le 0x10000000) {
                $head = ReadBytes $handle $base 8
                if ($head -and $head[0] -eq 0x4D -and $head[1] -eq 0x46 -and $head[2] -eq 0x50 -and $head[3] -eq 0x53 -and $head[7] -eq 1) {
                    $telemetry = $base
                    break
                }
            }
            $address = $base + $length
        }
        if ($telemetry -eq 0) { Start-Sleep -Seconds 3; $process.Refresh() }
    }
    if ($telemetry -eq 0) { exit 0 }

    # The VR pack's own block: mtControl holds the view mode and, at offset 48, the constants
    # -0.5, 0.1 and 1.0 (as big-endian floats), searched for in the 4 MB code cave.
    $control = [long] 0
    $cave = ReadBytes $handle $telemetry 0x400000
    if ($cave) {
        $latin = [Text.Encoding]::GetEncoding(28591)
        $text = $latin.GetString($cave)
        $signature = $latin.GetString([byte[]] (0xBF, 0, 0, 0, 0x3D, 0xCC, 0xCC, 0xCD, 0x3F, 0x80, 0, 0))
        $at = $text.IndexOf($signature, [StringComparison]::Ordinal)
        if ($at -ge 48 -and ($at % 4) -eq 0) { $control = $telemetry + $at - 48 }
    }

    # The glove block of the VR pack (mtHandCtl): its forward offset, prediction gain and jump limit
    # (20.0, 1.5 and 40000.0 as big-endian floats) sit at offsets 44, 48 and 52. The four glove
    # orientation presets are at 16, 20, 68 and 72; they are saved to $PresetFile when they change.
    $handCtl = [long] 0
    if ($cave -and $PresetFile) {
        $handSignature = $latin.GetString([byte[]] (0x41, 0xA0, 0, 0, 0x3F, 0xC0, 0, 0, 0x47, 0x1C, 0x40, 0))
        $found = $text.IndexOf($handSignature, [StringComparison]::Ordinal)
        if ($found -ge 44 -and ($found % 4) -eq 0) { $handCtl = $telemetry + $found - 44 }
    }
    $lastPresets = ''
    $lastCamera = ''
    $lastFp = ''

    # The counter blocks of the VR pack: the fireball one starts with 'MFST', the blow one has 'MMIC' at offset 52.
    $fireStat = [long] 0
    $micStat = [long] 0
    if ($cave -and $DiagOut) {
        $found = $text.IndexOf($latin.GetString([byte[]] (0x4D, 0x46, 0x53, 0x54)), [StringComparison]::Ordinal)
        if ($found -ge 0 -and ($found % 4) -eq 0) { $fireStat = $telemetry + $found }
        $found = $text.IndexOf($latin.GetString([byte[]] (0x4D, 0x4D, 0x49, 0x43)), [StringComparison]::Ordinal)
        if ($found -ge 52 -and (($found - 52) % 4) -eq 0) { $micStat = $telemetry + $found - 52 }
    }
    $lastDiag = ''
    $reasons = @('none', 'hands switch off', 'fireball switch off', 'right glove not drawn yet', 'camera behind Mario', 'not first person', 'right controller not tracked', 'hand points straight up or down')

    Set-Content -LiteralPath $Out -Value 'time,frames_per_s,steps_per_s,view' -Encoding ASCII
    $previousFrames = $null
    $previousSteps = $null
    $previousTime = $null
    while (-not $process.HasExited) {
        $block = ReadBytes $handle $telemetry 16
        if (-not $block) { break }
        $frames = BigUInt32 $block 8
        $steps = BigUInt32 $block 12
        $now = Get-Date
        $view = -1
        if ($control -ne 0) {
            $mode = ReadBytes $handle $control 32
            if ($mode) {
                if ((BigUInt32 $mode 0) -eq 1 -and (BigUInt32 $mode 28) -eq 1) { $view = 1 } else { $view = 0 }
            }
        }
        if ($null -ne $previousTime) {
            $seconds = ($now - $previousTime).TotalSeconds
            if ($seconds -gt 0.2 -and $frames -ge $previousFrames -and $steps -ge $previousSteps) {
                $line = [string]::Format($invariant, '{0:HH:mm:ss},{1:F1},{2:F1},{3}', $now, (($frames - $previousFrames) / $seconds), (($steps - $previousSteps) / $seconds), $view)
                Add-Content -LiteralPath $Out -Value $line -Encoding ASCII
            }
        }
        $previousFrames = $frames
        $previousSteps = $steps
        $previousTime = $now
        if ($handCtl -ne 0) {
            $ctl = ReadBytes $handle $handCtl 76
            if ($ctl) {
                $ml = BigUInt32 $ctl 16; $mr = BigUInt32 $ctl 20; $pl = BigUInt32 $ctl 68; $pr = BigUInt32 $ctl 72
                if ($ml -le 23 -and $mr -le 23 -and $pl -le 23 -and $pr -le 23) {
                    $now = [string]::Format($invariant, 'ML={0} MR={1} PL={2} PR={3}', $ml, $mr, $pl, $pr)
                    if ($lastPresets -eq '') {
                        # the numbers the session started with (defaults, or those restored): only later changes are saved
                        $lastPresets = $now
                    } elseif ($now -ne $lastPresets) {
                        Set-Content -LiteralPath $PresetFile -Value $now -Encoding ASCII
                        $lastPresets = $now
                    }
                }
            }
        }
        if ($handCtl -ne 0 -and $CameraFile) {
            # the camera-behind-Mario distance chosen with the right stick (mtEyeBackCtl+16, 8 bytes
            # before mtHandCtl): saved when it changes, so the launcher can put it back next time
            $cam = ReadBytes $handle ($handCtl - 8) 4
            if ($cam) {
                $dist = BigSingle $cam 0
                if ($dist -ge 80 -and $dist -le 600) {
                    $text3 = [string]::Format($invariant, '{0:F1}', $dist)
                    if ($lastCamera -eq '') { $lastCamera = $text3 }
                    elseif ($text3 -ne $lastCamera) {
                        Set-Content -LiteralPath $CameraFile -Value $text3 -Encoding ASCII
                        $lastCamera = $text3
                    }
                }
            }
        }
        if ($handCtl -ne 0 -and $FpFile) {
            # the first-person pull-back (mtFpBack, 28 bytes before mtHandCtl)
            $fpb = ReadBytes $handle ($handCtl - 28) 4
            if ($fpb) {
                $fp = BigSingle $fpb 0
                if ($fp -ge 0 -and $fp -le 600) {
                    $text4 = [string]::Format($invariant, '{0:F1}', $fp)
                    if ($lastFp -eq '') { $lastFp = $text4 }
                    elseif ($text4 -ne $lastFp) {
                        Set-Content -LiteralPath $FpFile -Value $text4 -Encoding ASCII
                        $lastFp = $text4
                    }
                }
            }
        }
        if ($DiagOut -and ($fireStat -ne 0 -or $micStat -ne 0)) {
            $text2 = @()
            $fs = $null
            if ($fireStat -ne 0) { $fs = ReadBytes $handle $fireStat 88 }
            if ($fs -and (BigUInt32 $fs 8) -gt 0) {
                $r1 = BigUInt32 $fs 16; $r2 = BigUInt32 $fs 28
                $n1 = 'code ' + $r1; if ($r1 -lt $reasons.Count) { $n1 = $reasons[$r1] }
                $n2 = 'code ' + $r2; if ($r2 -lt $reasons.Count) { $n2 = $reasons[$r2] }
                $text2 += [string]::Format($invariant, 'Fireball:  {0} thrown; start at the glove {1} times, direction of the hand {2} times', (BigUInt32 $fs 8), (BigUInt32 $fs 12), (BigUInt32 $fs 24))
                $text2 += [string]::Format($invariant, '           last time the start was not the glove: {0}; the direction was not the hand: {1}', $n1, $n2)
                $text2 += [string]::Format($invariant, '           glove update age at the throw: last {0}, worst {1} frames; X down to fireball: last {2}, longest {3} frames', (BigUInt32 $fs 36), (BigUInt32 $fs 40), (BigUInt32 $fs 48), (BigUInt32 $fs 52))
                $text2 += [string]::Format($invariant, '           last start {0:F0} {1:F0} {2:F0}, last direction {3:F2} {4:F2} {5:F2}', (BigSingle $fs 60), (BigSingle $fs 64), (BigSingle $fs 68), (BigSingle $fs 72), (BigSingle $fs 76), (BigSingle $fs 80))
            }
            $ms = $null
            if ($micStat -ne 0) { $ms = ReadBytes $handle $micStat 56 }
            if ($ms -and ((BigUInt32 $ms 32) + (BigUInt32 $ms 36) + (BigUInt32 $ms 40) + (BigUInt32 $ms 48)) -gt 0) {
                $text2 += [string]::Format($invariant, 'Blow:      the hand at the mouth turned on {0} times; the game asked {1} / {2} / {3} times, answered "blowing" {4} times', (BigUInt32 $ms 48), (BigUInt32 $ms 32), (BigUInt32 $ms 36), (BigUInt32 $ms 40), (BigUInt32 $ms 44))
            }
            $joined = ($text2 -join "`n")
            if ($joined -ne '' -and $joined -ne $lastDiag) {
                Set-Content -LiteralPath $DiagOut -Value $text2 -Encoding ASCII
                $lastDiag = $joined
            }
        }
        Start-Sleep -Seconds 1
        $process.Refresh()
    }
} catch {
    # never disturb the session
} finally {
    [void] [CvrMem]::CloseHandle($handle)
}
exit 0
