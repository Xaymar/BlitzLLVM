# RDNA 3 check: the 780M iGPU on Irkela (dGPU-only mode). OpenGL is pushed onto the iGPU with a per-app GPU preference for
# interop_repro.exe only (removed again at the end); Vulkan follows the GL context's LUID. Writes results_rdna3\.
param([string]$Out = "$PSScriptRoot\results_rdna3")
New-Item -ItemType Directory -Force -Path $Out | Out-Null
Add-Type -Namespace W -Name P -MemberDefinition '[DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint f);'
[W.P]::SetThreadExecutionState([uint32]2147483651) | Out-Null
$exe = Join-Path $PSScriptRoot "interop_repro.exe"
$key = "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences"
$old = (Get-ItemProperty -Path $key -Name $exe -ErrorAction SilentlyContinue).$exe
if (-not (Test-Path $key)) { New-Item -Path $key -Force | Out-Null }
Set-ItemProperty -Path $key -Name $exe -Value "GpuPreference=1;"   # 1 = power saving (iGPU)
try {
  $runs = @(
    @{ n = "r01_nt_base";       a = "--frames 300" },
    @{ n = "r02_nt_nosem";      a = "--no-import-sem" },
    @{ n = "r03_kmt";           a = "--handle kmt" },
    @{ n = "r04_keep_both";     a = "--keep both" },
    @{ n = "r05_keep_mem";      a = "--keep mem" },
    @{ n = "r06_keep_sem";      a = "--keep sem" },
    @{ n = "r07_finish_close";  a = "--finish-before-close" },
    @{ n = "r08_nt_core_full";  a = "--context core --usage full" }
  )
  $summary = @()
  foreach ($r in $runs) {
    $log = Join-Path $Out "$($r.n).txt"
    $t0 = Get-Date
    $p = Start-Process -FilePath $exe -ArgumentList $r.a -NoNewWindow -PassThru -RedirectStandardOutput $log -RedirectStandardError "$log.err"
    $null = $p.Handle
    if (-not $p.WaitForExit(90000)) { $p.Kill(); $code = "TIMEOUT" } else { $code = ('0x{0:X8}' -f $p.ExitCode) }
    $ms = [int]((Get-Date) - $t0).TotalMilliseconds
    $lines = Get-Content $log -ErrorAction SilentlyContinue
    $gl = ($lines | Select-String '^GL_RENDERER' | Select-Object -First 1).Line
    $last = ($lines | Select-String '^\[step\]|^RESULT|^\[FAIL\]' | Select-Object -Last 1).Line
    $crash = ($lines | Select-String '^\s+at ' | Select-Object -First 1).Line
    $summary += "{0,-18} exit {1,-10} {2,6} ms  {3}  last: {4}  {5}" -f $r.n, $code, $ms, $gl, $last, $crash
    Start-Sleep -Seconds 2
  }
  $summary | Tee-Object -FilePath (Join-Path $Out "summary.txt")
} finally {
  if ($old) { Set-ItemProperty -Path $key -Name $exe -Value $old } else { Remove-ItemProperty -Path $key -Name $exe -ErrorAction SilentlyContinue }
  [W.P]::SetThreadExecutionState([uint32]2147483648) | Out-Null
}
