# PowerShell build script
$ErrorActionPreference = "Inquire"

# Get Windows version
$winver = cmd /c ver
$winver = $winver -split 'Version' -split ' ' -split ']'
$winver = $winver[5]

Write-Output "Windows version detected."
Write-Output "Using base image mcr.microsoft.com/windows:$winver"

# Get OS architecture
$arch = $Env:PROCESSOR_ARCHITECTURE

# Name the downloaded installer
$File = "Setup.exe"

# Check architecture
if ($arch -eq "AMD64") {
    $arch = "x86_64"
    Write-Output "64-bit architecture detected."
    $File = "Setup64.exe"
}
elseif ($arch -eq "x86") {
    Write-Output "32-bit architecture detected."
}
else {
    $arch = "x86"
    Write-Output "Architecture not found. Defaulting to x86."
}

# Download Plex Media Server installer
$url = "https://downloads.plex.tv/plex-media-server-new/1.31.2.6810-a607d384f/windows/PlexMediaServer-1.31.2.6810-a607d384f-$arch.exe"
Write-Output "Downloading $url"
Invoke-WebRequest -URI $url -OutFile ".\PlexSetup\$File"

# Build image
Write-Output "Building Docker image..."
docker build --build-arg winver=$winver --build-arg arch=$arch -t plex-win .

# Save last build command to file
Set-Content -Path .\last_build_cmd.txt "docker build --build-arg winver=$winver --build-arg arch=$arch -t plex-win ."

Write-Output "Build script finished."
Read-Host -Prompt "You can now create the container with docker run"
