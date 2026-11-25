# Round 3: does closing the NT handle right after the import cause the crash? Writes results3\.
param([string]$Out = "$PSScriptRoot\results3")
New-Item -ItemType Directory -Force -Path $Out | Out-Null
Add-Type -Namespace W -Name P -MemberDefinition '[DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint f);'
[W.P]::SetThreadExecutionState([uint32]2147483651) | Out-Null
$hp = "interop_repro_hp.exe"; $ig = "interop_repro.exe"
$runs = @(
  @{ n = "c01_hp_nt_base";        exe = $hp; a = "--frames 300" },
  @{ n = "c02_hp_keep_both";      exe = $hp; a = "--keep both" },
  @{ n = "c03_hp_keep_mem";       exe = $hp; a = "--keep mem" },
  @{ n = "c04_hp_keep_sem";       exe = $hp; a = "--keep sem" },
  @{ n = "c05_hp_finish_close";   exe = $hp; a = "--finish-before-close" },
  @{ n = "c06_hp_keep_both_x3";   exe = $hp; a = "--keep both --frames 3000" },
  @{ n = "c07_hp_kmt_x3";         exe = $hp; a = "--handle kmt --frames 3000" },
  @{ n = "d01_ig_keep_both";      exe = $ig; a = "--keep both" },
  @{ n = "d02_ig_keep_mem";       exe = $ig; a = "--keep mem" },
  @{ n = "d03_ig_finish_close";   exe = $ig; a = "--finish-before-close" }
)
$summary = @()
foreach ($r in $runs) {
  $log = Join-Path $Out "$($r.n).txt"
  $t0 = Get-Date
  $p = Start-Process -FilePath (Join-Path $PSScriptRoot $r.exe) -ArgumentList $r.a -NoNewWindow -PassThru -RedirectStandardOutput $log -RedirectStandardError "$log.err"
  $null = $p.Handle
  if (-not $p.WaitForExit(90000)) { $p.Kill(); $code = "TIMEOUT" } else { $code = ('0x{0:X8}' -f $p.ExitCode) }
  $ms = [int]((Get-Date) - $t0).TotalMilliseconds
  $lines = Get-Content $log -ErrorAction SilentlyContinue
  $last = ($lines | Select-String '^\[step\]|^RESULT|^\[FAIL\]' | Select-Object -Last 1).Line
  $crash = ($lines | Select-String '^\s+at ' | Select-Object -First 1).Line
  $summary += "{0,-22} exit {1,-10} {2,6} ms  last: {3}  {4}" -f $r.n, $code, $ms, $last, $crash
  Start-Sleep -Seconds 2
}
$summary | Tee-Object -FilePath (Join-Path $Out "summary.txt")
[W.P]::SetThreadExecutionState([uint32]2147483648) | Out-Null
