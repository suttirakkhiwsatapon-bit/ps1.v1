$MemberDefinition = @'
[DllImport("kernel32.dll", SetLastError = true)]
public static extern IntPtr OpenProcess(uint dwDesiredAccess, bool bInheritHandle, uint dwProcessId);

[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, uint nSize, out int lpNumberOfBytesWritten);

[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool CloseHandle(IntPtr hObject);
'@

$Kernel32 = Add-Type -MemberDefinition $MemberDefinition -Name "Kernel32Utils" -Namespace "Win32" -PassThru

$ProcessName = "FiveM" 
$Process = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue

if ($null -eq $Process) {
    Write-Host "à¹„à¸¡à¹ˆà¸žà¸šà¹‚à¸›à¸£à¹€à¸‹à¸ª $ProcessName à¸à¸£à¸¸à¸“à¸²à¹€à¸›à¸´à¸”à¹€à¸à¸¡à¸«à¸£à¸·à¸­à¹‚à¸›à¸£à¹€à¸‹à¸ªà¹€à¸›à¹‰à¸²à¸«à¸¡à¸²à¸¢à¸à¹ˆà¸­à¸™" -ForegroundColor Red
    exit
}

# à¸„à¹ˆà¸² Patch Value: 44 35 3A BD 26 5C A7 40 00 00 20 41 00 00 46 41 00 00 80 3E
[byte[]]$PatchBytes = @(0x44, 0x35, 0x3A, 0xBD, 0x26, 0x5C, 0xA7, 0x40, 0x00, 0x00, 0x20, 0x41, 0x00, 0x00, 0x46, 0x41, 0x00, 0x00, 0x80, 0x3E)

# à¸«à¸¡à¸²à¸¢à¹€à¸«à¸•à¸¸: à¹ƒà¸™à¸—à¸²à¸‡à¸›à¸à¸´à¸šà¸±à¸•à¸´ à¸„à¹ˆà¸² Address à¸™à¸µà¹‰à¸ˆà¸°à¹€à¸›à¸¥à¸µà¹ˆà¸¢à¸™à¹à¸›à¸¥à¸‡à¸—à¸¸à¸à¸„à¸£à¸±à¹‰à¸‡à¸—à¸µà¹ˆà¹€à¸›à¸´à¸”à¹‚à¸›à¸£à¹à¸à¸£à¸¡à¹ƒà¸«à¸¡à¹ˆ (Dynamic Memory)
$TargetAddress = [IntPtr]0x140000000 # à¹ƒà¸ªà¹ˆà¸•à¸³à¹à¸«à¸™à¹ˆà¸‡ Address à¸—à¸µà¹ˆà¸„à¹‰à¸™à¸žà¸šà¸ˆà¸²à¸à¹‚à¸›à¸£à¹à¸à¸£à¸¡ Scan

$ProcessHandle = $Kernel32::OpenProcess(0x001F0FFF, $false, $Process.Id) # 0x001F0FFF à¸„à¸·à¸­ PROCESS_ALL_ACCESS

if ($ProcessHandle -ne [IntPtr]::Zero) {
    $BytesWritten = 0
    $Success = $Kernel32::WriteProcessMemory($ProcessHandle, $TargetAddress, $PatchBytes, [uint32]$PatchBytes.Length, [ref]$BytesWritten)
    
    if ($Success) {
        Write-Host "à¹€à¸‚à¸µà¸¢à¸™à¸‚à¹‰à¸­à¸¡à¸¹à¸¥à¸ªà¸³à¹€à¸£à¹‡à¸ˆà¸ˆà¸³à¸™à¸§à¸™ $BytesWritten à¹„à¸šà¸•à¹Œ à¸¥à¸‡à¹ƒà¸™à¸•à¸³à¹à¸«à¸™à¹ˆà¸‡ $TargetAddress" -ForegroundColor Green
    } else {
        Write-Host "à¹„à¸¡à¹ˆà¸ªà¸²à¸¡à¸²à¸£à¸–à¹€à¸‚à¸µà¸¢à¸™à¸‚à¹‰à¸­à¸¡à¸¹à¸¥à¸¥à¸‡à¹ƒà¸™à¸•à¸³à¹à¸«à¸™à¹ˆà¸‡à¸”à¸±à¸‡à¸à¸¥à¹ˆà¸²à¸§à¹„à¸”à¹‰ (à¸ªà¸´à¸—à¸˜à¸´à¹Œà¹„à¸¡à¹ˆà¹€à¸žà¸µà¸¢à¸‡à¸žà¸­ à¸«à¸£à¸·à¸­ Address à¹„à¸¡à¹ˆà¸–à¸¹à¸à¸•à¹‰à¸­à¸‡)" -ForegroundColor Red
    }
    
    # à¸›à¸´à¸” Handle à¹€à¸ªà¸¡à¸­à¸«à¸¥à¸±à¸‡à¹ƒà¸Šà¹‰à¸‡à¸²à¸™à¹€à¸ªà¸£à¹‡à¸ˆ
    [void]$Kernel32::CloseHandle($ProcessHandle)
} else {
    Write-Host "à¹„à¸¡à¹ˆà¸ªà¸²à¸¡à¸²à¸£à¸–à¹€à¸›à¸´à¸” Connection à¹„à¸›à¸¢à¸±à¸‡à¹‚à¸›à¸£à¹€à¸‹à¸ªà¹„à¸”à¹‰ à¸à¸£à¸¸à¸“à¸²à¸£à¸±à¸™ PowerShell à¸”à¹‰à¸§à¸¢à¸ªà¸´à¸—à¸˜à¸´à¹Œ Administrator" -ForegroundColor Red
}
