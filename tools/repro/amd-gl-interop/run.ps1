# Runs the interop repro matrix. Usage: powershell -ExecutionPolicy Bypass -File run.ps1 [-Out <dir>]
param([string]$Out = "$PSScriptRoot\results")
New-Item -ItemType Directory -Force -Path $Out | Out-Null
Add-Type -Namespace W -Name P -MemberDefinition '[DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint f);'
[W.P]::SetThreadExecutionState(0x80000003) | Out-Null   # ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED
$runs = @(
  @{ n = "01_auto_min";        exe = "interop_repro.exe";    a = "--usage min" },
  @{ n = "02_auto_min_strict"; exe = "interop_repro.exe";    a = "--usage min --strict" },
  @{ n = "03_gpu0_min";        exe = "interop_repro.exe";    a = "--vk-gpu 0 --usage min" },
  @{ n = "04_gpu1_min";        exe = "interop_repro.exe";    a = "--vk-gpu 1 --usage min" },
  @{ n = "05_gpu0_full";       exe = "interop_repro.exe";    a = "--vk-gpu 0 --usage full" },
  @{ n = "06_gpu1_full";       exe = "interop_repro.exe";    a = "--vk-gpu 1 --usage full" },
  @{ n = "07_hp_auto_min";     exe = "interop_repro_hp.exe"; a = "--usage min" },
  @{ n = "08_hp_gpu0_min";     exe = "interop_repro_hp.exe"; a = "--vk-gpu 0 --usage min" },
  @{ n = "09_hp_gpu1_min";     exe = "interop_repro_hp.exe"; a = "--vk-gpu 1 --usage min" },
  @{ n = "10_hp_gpu0_full";    exe = "interop_repro_hp.exe"; a = "--vk-gpu 0 --usage full" },
  @{ n = "11_hp_gpu1_full";    exe = "interop_repro_hp.exe"; a = "--vk-gpu 1 --usage full" }
)
$summary = @()
foreach ($r in $runs) {
  $log = Join-Path $Out "$($r.n).txt"
  $p = Start-Process -FilePath (Join-Path $PSScriptRoot $r.exe) -ArgumentList $r.a -NoNewWindow -PassThru -RedirectStandardOutput $log -RedirectStandardError "$log.err"
  if (-not $p.WaitForExit(60000)) { $p.Kill(); $code = "TIMEOUT" } else { $code = ('0x{0:X8}' -f $p.ExitCode) }
  $last = (Get-Content $log -ErrorAction SilentlyContinue | Select-String '^\[step\]|^RESULT|^\[FAIL\]' | Select-Object -Last 1).Line
  $summary += "{0,-20} exit {1,-10} last: {2}" -f $r.n, $code, $last
  Start-Sleep -Seconds 2
}
$summary | Tee-Object -FilePath (Join-Path $Out "summary.txt")
[W.P]::SetThreadExecutionState(0x80000000) | Out-Null
