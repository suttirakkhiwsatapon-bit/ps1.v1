Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinTimer {
    [DllImport("winmm.dll")]
    public static extern uint timeBeginPeriod(uint uMilliseconds);
}
"@

function Show-Status {
    param([string]$Message, [string]$Color = "White")
    $global:statusBox.SelectionColor = [System.Drawing.Color]::$Color
    $global:statusBox.AppendText($Message + [Environment]::NewLine)
    $global:statusBox.ScrollToCaret()
    Start-Sleep -Milliseconds 180
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "lxstbossproject"
$form.Width = 1140
$form.Height = 760
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::Black
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false
$form.TopMost = $true

$imagePath = Join-Path $PSScriptRoot "wallpaper.jpg"
if (Test-Path $imagePath) {
    $bg = New-Object System.Windows.Forms.PictureBox
    $bg.Dock = "Fill"
    $bg.SizeMode = "StretchImage"
    $bg.Image = [System.Drawing.Image]::FromFile($imagePath)
    $form.Controls.Add($bg)
    $bg.SendToBack()
}

$overlay = New-Object System.Windows.Forms.Panel
$overlay.Dock = "Fill"
$overlay.BackColor = [System.Drawing.Color]::FromArgb(75,0,0,0)
$form.Controls.Add($overlay)

$logoPath = Join-Path $PSScriptRoot "logo.png"

if (Test-Path $logoPath) {
    $logo = New-Object System.Windows.Forms.PictureBox
    $logo.Image = [System.Drawing.Image]::FromFile($logoPath)
    $logo.SizeMode = "Zoom"
    $logo.Width = 420
    $logo.Height = 180
    $logo.Left = ($form.ClientSize.Width - $logo.Width) / 2
    $logo.Top = 10
    $overlay.Controls.Add($logo)
}

$title = New-Object System.Windows.Forms.Label
$title.Text = "lxstbossproject"
$title.ForeColor = [System.Drawing.Color]::White
$title.Font = New-Object System.Drawing.Font("Arial",22,[System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Left = 455
$title.Top = 20
$overlay.Controls.Add($title)

# (ซ่อนระบบรหัส)
$codeLabel = New-Object System.Windows.Forms.Label
$codeBox   = New-Object System.Windows.Forms.TextBox
$codeLabel.Visible = $false
$codeBox.Visible   = $false

$startBtn = New-Object System.Windows.Forms.Button
$startBtn.Text = "ACTIVATE"
$startBtn.Left = 450
$startBtn.Top = 176
$startBtn.Width = 240
$startBtn.Height = 42
$startBtn.BackColor = [System.Drawing.Color]::Black
$startBtn.ForeColor = [System.Drawing.Color]::White
$overlay.Controls.Add($startBtn)

$statusBox = New-Object System.Windows.Forms.RichTextBox
$statusBox.Left = 80
$statusBox.Top = 245
$statusBox.Width = 960
$statusBox.Height = 430
$statusBox.BackColor = [System.Drawing.Color]::FromArgb(210,8,8,8)
$statusBox.ForeColor = [System.Drawing.Color]::Black
$statusBox.Font = New-Object System.Drawing.Font("Consolas",11,[System.Drawing.FontStyle]::Bold)
$statusBox.ReadOnly = $true
$overlay.Controls.Add($statusBox)

$startBtn.Add_Click({
    $statusBox.Clear()
    try {
Show-Status "╔════════════════════════════════════════════════════════════╗" "DeepSkyBlue"
        Show-Status "║                    LXSTBOSS.SETTING                    ║" "Black"`
        Show-Status "╚════════════════════════════════════════════════════════════╝" "DeepSkyBlue"
        Show-Status ""

        Show-Status "[ SYS  ] Enabling 1ms timer precision..." "Black"
        [WinTimer]::timeBeginPeriod(1) | Out-Null


        Show-Status "[ INPUT] Keyboard repeat speed tuning..." "Black"
        Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value "0"
        Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value "31"

        Show-Status "[ INPUT] Mouse acceleration off..." "Black"
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0"
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0"
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0"
        
        Show-Status "[ NET  ] Flushing DNS cache..." "Black"
        Start-Process -WindowStyle Hidden -FilePath "ipconfig.exe" -ArgumentList "/flushdns" -Wait

        Show-Status "[ NET  ] Optimizing TCP profile..." "Black"
        Start-Process -WindowStyle Hidden -FilePath "netsh.exe" -ArgumentList "int tcp set global autotuninglevel=disabled" -Wait
        Start-Process -WindowStyle Hidden -FilePath "netsh.exe" -ArgumentList "int tcp set global rss=enabled" -Wait
        Start-Process -WindowStyle Hidden -FilePath "netsh.exe" -ArgumentList "int tcp set global chimney=enabled" -Wait

        Show-Status "[ APP  ] Closing heavy background apps..." "Black"
        $apps = "OneDrive","Skype","Teams","XboxAppServices","YourPhone","SteamWebHelper","Copilot"
        foreach($a in $apps){
            Get-Process $a -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        }

        Show-Status "[ GPU ] loading.." "Black"
$Path1 = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
if (!(Test-Path $Path1)) { New-Item -Path $Path1 -Force }
Set-ItemProperty -Path $Path1 -Name "GPU Priority" -Value 8 -Type DWord
Set-ItemProperty -Path $Path1 -Name "Priority" -Value 6 -Type DWord
Set-ItemProperty -Path $Path1 -Name "Scheduling Category" -Value "High" -Type String
Set-ItemProperty -Path $Path1 -Name "SFIO Priority" -Value "High" -Type String
$Path2 = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
if (!(Test-Path $Path2)) { New-Item -Path $Path2 -Force }
Set-ItemProperty -Path $Path2 -Name "NetworkThrottlingIndex" -Value 0xffffffff -Type DWord
Set-ItemProperty -Path $Path2 -Name "SystemResponsiveness" -Value 0 -Type DWord
$Path3 = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
if (!(Test-Path $Path3)) { New-Item -Path $Path3 -Force }
Set-ItemProperty -Path $Path3 -Name "Win32PrioritySeparation" -Value 38 -Type DWord


        Show-Status "[ GODSETTING ] loading" "RED"
        Start-Process reg.exe -ArgumentList 'add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 0 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKCU\Control Panel\Mouse" /v MouseSensitivity /t REG_SZ /d 10 /f' -Wait -NoNewWindow

Start-Process reg.exe -ArgumentList 'add "HKCU\Control Panel\Keyboard" /v KeyboardDelay /t REG_SZ /d 0 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKCU\Control Panel\Keyboard" /v KeyboardSpeed /t REG_SZ /d 31 /f' -Wait -NoNewWindow

Start-Process reg.exe -ArgumentList 'add "HKCU\Control Panel\Accessibility\StickyKeys" /v Flags /t REG_SZ /d 506 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKCU\Control Panel\Accessibility\Keyboard Response" /v Flags /t REG_SZ /d 122 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKCU\Control Panel\Accessibility\ToggleKeys" /v Flags /t REG_SZ /d 58 /f' -Wait -NoNewWindow

Start-Process reg.exe -ArgumentList 'add "HKLM\SYSTEM\CurrentControlSet\Services\USB" /v DisableSelectiveSuspend /t REG_DWORD /d 1 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SYSTEM\CurrentControlSet\Services\HidUsb" /v DisablePowerManagement /t REG_DWORD /d 1 /f' -Wait -NoNewWindow

Start-Process reg.exe -ArgumentList 'add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f' -Wait -NoNewWindow

Start-Process reg.exe -ArgumentList 'add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehavior /t REG_DWORD /d 2 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehaviorMode /t REG_DWORD /d 2 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKCU\System\GameConfigStore" /v GameDVR_HonorUserFSEBehaviorMode /t REG_DWORD /d 1 /f' -Wait -NoNewWindow

Start-Process reg.exe -ArgumentList 'add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 26 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /t REG_DWORD /d 1 /f' -Wait -NoNewWindow
Start-Process powercfg.exe -ArgumentList '-setactive SCHEME_MIN' -Wait -NoNewWindow

Start-Process reg.exe -ArgumentList 'add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f' -Wait -NoNewWindow

Start-Process reg.exe -ArgumentList 'add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v AlwaysOn /t REG_DWORD /d 1 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NoLazyMode /t REG_DWORD /d 1 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f' -Wait -NoNewWindow

Start-Process reg.exe -ArgumentList 'add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Priority /t REG_DWORD /d 6 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Latency Sensitive" /t REG_SZ /d True /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Only" /t REG_SZ /d False /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /t REG_DWORD /d 10000 /f' -Wait -NoNewWindow

Start-Process reg.exe -ArgumentList 'add "HKLM\SYSTEM\CurrentControlSet\Services\MMCSS" /v Start /t REG_DWORD /d 2 /f' -Wait -NoNewWindow

Start-Process reg.exe -ArgumentList 'add "HKLM\SYSTEM\CurrentControlSet\Services\Ndu" /v Start /t REG_DWORD /d 4 /f' -Wait -NoNewWindow

Start-Process netsh.exe -ArgumentList 'int tcp set global autotuninglevel=normal' -Wait -NoNewWindow
Start-Process netsh.exe -ArgumentList 'int tcp set global rss=enabled' -Wait -NoNewWindow
Start-Process netsh.exe -ArgumentList 'int tcp set global chimney=disabled' -Wait -NoNewWindow
Start-Process netsh.exe -ArgumentList 'int tcp set global timestamps=disabled' -Wait -NoNewWindow
Start-Process netsh.exe -ArgumentList 'int tcp set global ecncapability=disabled' -Wait -NoNewWindow
Start-Process netsh.exe -ArgumentList 'int tcp set global rsc=disabled' -Wait -NoNewWindow
Start-Process netsh.exe -ArgumentList 'int tcp set global fastopen=enabled' -Wait -NoNewWindow

Start-Process reg.exe -ArgumentList 'add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpMaxDataRetransmissions /t REG_DWORD /d 5 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpTimedWaitDelay /t REG_DWORD /d 30 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v MaxUserPort /t REG_DWORD /d 65534 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v NonBestEffortLimit /t REG_DWORD /d 0 /f' -Wait -NoNewWindow

Start-Process reg.exe -ArgumentList 'add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v MaxCacheTtl /t REG_DWORD /d 86400 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v MaxNegativeCacheTtl /t REG_DWORD /d 0 /f' -Wait -NoNewWindow

Start-Process reg.exe -ArgumentList 'add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DisablePagingExecutive /t REG_DWORD /d 1 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 0 /f' -Wait -NoNewWindow

Start-Process bcdedit.exe -ArgumentList '/deletevalue useplatformclock' -Wait -NoNewWindow
Start-Process bcdedit.exe -ArgumentList '/set disabledynamictick yes' -Wait -NoNewWindow
Start-Process bcdedit.exe -ArgumentList '/set tscsyncpolicy Enhanced' -Wait -NoNewWindow

Start-Process ipconfig.exe -ArgumentList '/flushdns' -Wait -NoNewWindow

Show-Status "[ internet ] loading.." "Black"
Start-Process netsh.exe -ArgumentList 'int tcp set global autotuninglevel=normal' -Wait -NoNewWindow
Start-Process netsh.exe -ArgumentList 'int tcp set global rss=enabled' -Wait -NoNewWindow
Start-Process netsh.exe -ArgumentList 'int tcp set global ecncapability=disabled' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f' -Wait -NoNewWindow
Start-Process netsh.exe -ArgumentList 'int tcp set global autotuninglevel=normal' -Wait -NoNewWindow
Start-Process netsh.exe -ArgumentList 'int tcp set global rss=enabled' -Wait -NoNewWindow
Start-Process netsh.exe -ArgumentList 'int tcp set global ecncapability=disabled' -Wait -NoNewWindow
Start-Process powercfg.exe -ArgumentList '-h off' -Wait -NoNewWindow
Start-Process powercfg.exe -ArgumentList '-setacvalueindex scheme_current SUB_USB USBSELECTIVE SUSPEND 0' -Wait -NoNewWindow
Start-Process powercfg.exe -ArgumentList '-S scheme_current' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpDelAckTicks /t REG_DWORD /d 0 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v SynAttackProtect /t REG_DWORD /d 1 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpDelAckTicks /t REG_DWORD /d 0 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v SynAttackProtect /t REG_DWORD /d 1 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKCU\Control Panel\Desktop" /v MouseDuration /t REG_DWORD /d 0 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKCU\Control Panel\Desktop" /v MouseThreshold1 /t REG_DWORD /d 0 /f' -Wait -NoNewWindow
Start-Process reg.exe -ArgumentList 'add "HKCU\Control Panel\Desktop" /v MouseThreshold2 /t REG_DWORD /d 0 /f' -Wait -NoNewWindow

        Show-Status "[ DONE ] lxstbossproject READY" "Lime"
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Run this program as Administrator.", "lxstbossproject")
        Show-Status "[ WARN ] Some commands require administrator rights." "Orange"
    }
})
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
