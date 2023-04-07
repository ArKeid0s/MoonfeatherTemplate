$externalTools = Get-Content -Path "external-tools-config.json" | ConvertFrom-Json

$vsRegPath = "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\VisualStudio\17.0_*\External Tools"
$vsRegKey = Get-ChildItem -Path $vsRegPath | Select-Object -First 1

foreach ($tool in $externalTools) {
    $nextIndex = (Get-ItemProperty -Path $vsRegKey.PSPath).ToolNum
    $toolPath = "$($vsRegKey.PSPath)\Tool$nextIndex"

    New-Item -Path $toolPath
    Set-ItemProperty -Path $toolPath -Name DisplayName -Value $tool.Title
    Set-ItemProperty -Path $toolPath -Name Command -Value $tool.Command
    Set-ItemProperty -Path $toolPath -Name Arguments -Value $tool.Arguments
    Set-ItemProperty -Path $toolPath -Name InitialDirectory -Value $tool.InitialDirectory

    Set-ItemProperty -Path $vsRegKey.PSPath -Name ToolNum -Value ($nextIndex + 1)
}

Write-Host "External tools added successfully."
