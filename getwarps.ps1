# Edited version of starrailstation.com's method
# based on repo https://github.com/yeci226/HSR
Add-Type -AssemblyName System.Web
$ProgressPreference = 'SilentlyContinue'

# Find Player log
Write-Output "Finding game..."
$logContent = Get-Content -Path "$([Environment]::GetFolderPath('ApplicationData'))\..\LocalLow\Cognosphere\Star Rail\Player.log"

# Find Game Folder
foreach ($line in $logContent) {
    if ($line -ne $null -and $line.StartsWith("Loading player data from")) {
        $gamePath = $line -replace "Loading player data from |\/data.unity3d", ""
        break
    }
}

if ($gamePath -ne $null) {
	# Get Current Game Version
	$version = Get-ChildItem -Path "$gamePath/webCaches" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    # Find Gacha Url
    Write-Output "Finding Gacha Url..."
    $cacheDataLines = Get-Content -Path "$gamePath/webCaches/$version/Cache/Cache_Data/data_2" -Raw -Encoding UTF8 -PipelineVariable cacheData |
    ForEach-Object {
        $_ -split '1/0/'
    }
    $foundUrl = $false

    foreach ($line in $cacheDataLines) {
		if ($line -match '^http.*getGachaLog') {
			$url = ($line -split "\0")[0]

			$response = Invoke-WebRequest -Uri $url -ContentType "application/json" -UseBasicParsing | ConvertFrom-Json

			if ($response.retcode -eq 0) {
				Write-Output $url
				Set-Clipboard -Value $url
				Write-Output "Warp History Url has been saved to clipboard."
				$foundUrl = $true
				break
			}
		}
	}

    if (-not $foundUrl) {
        Write-Output "Unable to find Gacha Url. Please open warp history in-game."
    }
	
} else {
    Write-Output "Unable to find Game Path. Please try re-opening the game."
}

# Remove variables from memory
$appData=$logPath=$logContent=$gamePath=$cacheData=$cacheDataLines=$null

Write-Output "Completed"
