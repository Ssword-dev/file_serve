# !! Do not edit without knowledge about what you are about to do !!

$zipName = "file_serve-latest.zip"
$distUrl = "https://github.com/Ssword-dev/file_serve/releases/download/main/windows-exe.zip"

# locate the bootstrap for PATH and writes
$outDir = Join-Path -Path (Get-Location) -ChildPath "file_serve_bootstrap"

# download zip
Invoke-WebRequest -Uri $distUrl -OutFile $zipName

# force extraction
Expand-Archive -Path $zipName -DestinationPath $outDir -Force

Write-Output "Extraction complete to $outDir, adding to PATH..."

$envPath = [Environment]::GetEnvironmentVariable("Path", "User")
if (-not $envPath.Split(";") -contains $outDir) {
    [Environment]::SetEnvironmentVariable("Path", "$envPath;$outDir", "User")
    Write-Output "Path updated!"
} else {
    Write-Output "Path already contains bootstrap dir"
}

# set path to the executable
$ExecutableProgramPath = Join-Path -Path $outDir -ChildPath "file_serve.exe"

# create a desktop shortcut
$shortcutPath = Join-Path -Path $env:USERPROFILE -ChildPath "Desktop\file_serve.lnk"
$wshShell = New-Object -ComObject WScript.Shell
$shortcut = $wshShell.CreateShortcut($shortcutPath)

$shortcut.TargetPath = $ExecutableProgramPath
$shortcut.WorkingDirectory = Split-Path $ExecutableProgramPath
$shortcut.WindowStyle = 1
$shortcut.Description = "Shortcut to File Serve"
$shortcut.IconLocation = "$ExecutableProgramPath, 0"
$shortcut.Save()

Write-Output "Shortcut created at $shortcutPath"
