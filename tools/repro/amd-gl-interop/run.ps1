# Runs the interop repro matrix (round 2). Usage: powershell -ExecutionPolicy Bypass -File run.ps1 [-Out <dir>]
param([string]$Out = "$PSScriptRoot\results2")
New-Item -ItemType Directory -Force -Path $Out | Out-Null
Add-Type -Namespace W -Name P -MemberDefinition '[DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint f);'
[W.P]::SetThreadExecutionState([uint32]2147483651) | Out-Null   # ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED
$hp = "interop_repro_hp.exe"; $ig = "interop_repro.exe"
# hp = PowerXpress export, OpenGL on the RX 6600M (as BlitzLLVM programs). --vk-gpu -1 = Vulkan device with the GL context's LUID.
$runs = @(
  @{ n = "a01_hp_base";          exe = $hp; a = "" },
  @{ n = "a02_hp_nosem";         exe = $hp; a = "--no-import-sem" },
  @{ n = "a03_hp_noblit";        exe = $hp; a = "--no-blit" },
  @{ n = "a04_hp_nosem_noblit";  exe = $hp; a = "--no-import-sem --no-blit" },
  @{ n = "a05_hp_kmt";           exe = $hp; a = "--handle kmt" },
  @{ n = "a06_hp_core";          exe = $hp; a = "--context core" },
  @{ n = "a07_hp_core_full";     exe = $hp; a = "--context core --usage full" },
  @{ n = "a08_hp_kmt_core_full"; exe = $hp; a = "--handle kmt --context core --usage full" },
  @{ n = "a09_hp_linear";        exe = $hp; a = "--tiling linear" },
  @{ n = "a10_hp_linear_full";   exe = $hp; a = "--tiling linear --usage full" },
  @{ n = "b01_ig_base";          exe = $ig; a = "" },
  @{ n = "b02_ig_kmt";           exe = $ig; a = "--handle kmt" },
  @{ n = "b03_ig_core_full";     exe = $ig; a = "--context core --usage full" },
  @{ n = "b04_ig_linear";        exe = $ig; a = "--tiling linear" },
  @{ n = "b05_ig_nosem";         exe = $ig; a = "--no-import-sem" }
)
$summary = @()
foreach ($r in $runs) {
  $log = Join-Path $Out "$($r.n).txt"
  $args2 = if ($r.a) { $r.a } else { "--frames 300" }
  $t0 = Get-Date
  $p = Start-Process -FilePath (Join-Path $PSScriptRoot $r.exe) -ArgumentList $args2 -NoNewWindow -PassThru -RedirectStandardOutput $log -RedirectStandardError "$log.err"
  $null = $p.Handle   # PS 5.1 keeps ExitCode only when the handle is read early.
  if (-not $p.WaitForExit(60000)) { $p.Kill(); $code = "TIMEOUT" } else { $code = ('0x{0:X8}' -f $p.ExitCode) }
  $ms = [int]((Get-Date) - $t0).TotalMilliseconds
  $lines = Get-Content $log -ErrorAction SilentlyContinue
  $last = ($lines | Select-String '^\[step\]|^RESULT|^\[FAIL\]' | Select-Object -Last 1).Line
  $crash = ($lines | Select-String '^\s+at ' | Select-Object -First 1).Line
  $summary += "{0,-22} exit {1,-10} {2,6} ms  last: {3}  {4}" -f $r.n, $code, $ms, $last, $crash
  Start-Sleep -Seconds 2
}
$summary | Tee-Object -FilePath (Join-Path $Out "summary.txt")
[W.P]::SetThreadExecutionState([uint32]2147483648) | Out-Null
