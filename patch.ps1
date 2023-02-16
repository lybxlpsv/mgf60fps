[Environment]::CurrentDirectory = (Get-Location -PSProvider FileSystem).ProviderPath

if ( -Not(Test-Path "eboot.bin")) {
    Write-Output "Put your eboot.bin in this folder."
    Start-Sleep -Seconds 2
    Return
}

.\bin\vita-unmake-fself.exe eboot.bin
$FileHash = Get-FileHash eboot.bin.elf -Algorithm MD5
$bytes = [System.IO.File]::ReadAllBytes("eboot.bin.elf")

if ( -Not(Test-Path "output")) {
    New-Item "output" -ItemType Directory
}

[bool] $patched = 0

# MGF Patch based on Diva X 60fps patch by someone idk who
if ($FileHash.Hash -eq "BAF63B678E090A47F4C0CEA0478856E9") {
    Write-Output "Patching 60fps Miracle Girls Festival"
    $bytes[0x4e464] = 0x1
    $bytes[0x4e5c0] = 0xf7
    $patched = 1
}

if ($patched) {
    [System.IO.File]::WriteAllBytes("output\eboot.bin.elf", $bytes)

    .\bin\vita-make-fself.exe output\eboot.bin.elf output\eboot.bin

    Remove-Item eboot.bin.elf
    Remove-Item output/eboot.bin.elf

    Write-Output "Done. output\eboot.bin"
}
else {
    Write-Output "Game is not supported."
    Remove-Item eboot.bin.elf
}

Start-Sleep -Seconds 2

