updated file >-

build_plugins.ps1

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "        PiERP - Plugin Compilation & Deployment           " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

$IsWindowsOS = ($env:OS -like "*Windows*") -or ($null -ne $IsWindows -and $IsWindows)

# 1. Load tool paths from root .env
$dotEnv = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\.env"))
if (Test-Path $dotEnv) {
    Write-Host "[INFO] Loading tool paths from $dotEnv" -ForegroundColor Cyan
    foreach ($line in Get-Content $dotEnv) {
        if ($line -match '^\s*#' -or $line -match '^\s*$') { continue }
        if ($line -match '^\s*([^=]+?)\s*=\s*(.*)\s*$') {
            Set-Item -Path "Env:$($matches[1].Trim())" -Value $matches[2].Trim()
        }
    }
} else {
    Write-Host "[WARNING] .env not found at $dotEnv — ensure JAVA_HOME and MAVEN_HOME are set." -ForegroundColor Yellow
}
$env:PATH = "$env:JAVA_HOME\bin;$env:MAVEN_HOME\bin;$env:PATH"
$env:MAVEN_OPTS = "-Dhttps.protocols=TLSv1.2 -Djdk.tls.client.protocols=TLSv1.2"
$localRepo = Resolve-Path "$PSScriptRoot\..\m2-local-repo" -ErrorAction SilentlyContinue
if ($localRepo -and (Get-ChildItem $localRepo -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1)) {
    $env:MAVEN_OPTS += " -Dmaven.repo.local=$localRepo"
    Write-Host "[INFO] Using project-local Maven repo: $localRepo" -ForegroundColor Cyan
} else {
    Write-Host "[INFO] m2-local-repo empty or missing — using default ~/.m2" -ForegroundColor Yellow
}

$bundlesInfoPath  = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\docker-image\image-builder\build-plugins\custom-bundles.info"))
$mandatoryModules = @("idempiere-rest", "com.pipra.dashboard.react")

# ── Build target selection ────────────────────────────────────────────────────
Write-Host ""
$choice = (Read-Host "Build [A]ll plugins, [M]andatory plugins, or [S]pecific? (default: A)").Trim().ToUpper()
if ($choice -eq 'M') {
    $BuildTarget = "mandatory"
    Write-Host "[INFO] Building mandatory plugins: $($mandatoryModules -join ', ')" -ForegroundColor Yellow
} elseif ($choice -eq 'S') {
    # List available modules from parent pom.xml
    [xml]$parentPom = Get-Content (Join-Path $PSScriptRoot "pom.xml")
    $available = @($parentPom.project.modules.module)
    Write-Host "Available plugins:" -ForegroundColor Cyan
    for ($i = 1; $i -le $available.Count; $i++) {
        Write-Host "  [$i] $($available[$i-1])" -ForegroundColor Cyan
    }
    $selection = (Read-Host "Enter number or path").Trim()
    if ($selection -match '^\d+$') {
        $idx = [int]$selection - 1
        if ($idx -lt 0 -or $idx -ge $available.Count) {
            Write-Host "[ERROR] Number out of range." -ForegroundColor Red
            exit 1
        }
        $BuildTarget = $available[$idx]
    } else {
        $BuildTarget = $selection
    }
    if (-not $BuildTarget -or -not (Test-Path (Join-Path $PSScriptRoot $BuildTarget))) {
        Write-Host "[ERROR] Module '$BuildTarget' not found." -ForegroundColor Red
        exit 1
    }
    Write-Host "[INFO] Building: $BuildTarget" -ForegroundColor Yellow
} else {
    $BuildTarget = "all"
    Write-Host "[INFO] Building: all plugins" -ForegroundColor Yellow
}
Write-Host ""

# ── Migration mode (specific plugin only) ────────────────────────────────────
$useMigration = $false
if ($BuildTarget -ne "all" -and $BuildTarget -ne "mandatory") {
    $mChoice = (Read-Host "Plugin SQL mode: [P]ackin (2Pack) or [M]igration (direct SQL)? (default: P)").Trim().ToUpper()
    $useMigration = ($mChoice -eq 'M')
    if ($useMigration) {
        Write-Host "[INFO] Migration mode — SQL will be staged for direct psql deployment." -ForegroundColor Yellow
    }
}
Write-Host ""

# ── Helper: $$-aware SQL statement splitter ────────────────────────────────
# Splits on ; only when NOT inside a $$ ... $$ dollar-quote block.
# Returns an array of statement strings with their trailing ; removed.
function Split-SqlStatements {
    param([string]$sql)
    Add-Type -AssemblyName System.Collections -ErrorAction SilentlyContinue
    $results  = [System.Collections.Generic.List[string]]::new()
    $buf      = [System.Text.StringBuilder]::new()
    $inDollar = $false
    $i        = 0
    while ($i -lt $sql.Length) {
        if ($i + 1 -lt $sql.Length -and $sql[$i] -eq '$' -and $sql[$i+1] -eq '$') {
            [void]$buf.Append('$$')
            $inDollar = -not $inDollar
            $i += 2
            continue
        }
        if ($sql[$i] -eq ';' -and -not $inDollar) {
            $stmt = $buf.ToString().Trim()
            if ($stmt.Length -gt 0 -and ($stmt -replace '(?s)(--[^\n]*\n|\s)+', '').Length -gt 0) {
                $results.Add($stmt)
            }
            [void]$buf.Clear()
            $i++
            continue
        }
        [void]$buf.Append($sql[$i])
        $i++
    }
    $stmt = $buf.ToString().Trim()
    if ($stmt.Length -gt 0 -and ($stmt -replace '(?s)(--[^\n]*\n|\s)+', '').Length -gt 0) {
        $results.Add($stmt)
    }
    return $results
}

# 2. For each plugin that has migration/postgresql/packin/, generate META-INF/2Pack_*.zip
Write-Host "`n[INFO] Checking for packin/ folders to generate 2Pack ZIPs..." -ForegroundColor Yellow
Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue

$topLevelDirs = Get-ChildItem -Path $PSScriptRoot -Directory |
    Where-Object { $BuildTarget -eq "all" -or $_.Name -eq $BuildTarget -or ($BuildTarget -eq "mandatory" -and $mandatoryModules -contains $_.Name) }

# Expand any parent folder (e.g. com.pipra.dashboard.widgets) into its sub-plugin dirs
$allPluginDirs = $topLevelDirs | ForEach-Object {
    $packInTest = Join-Path $_.FullName "migration\postgresql\packin"
    $metaInfTest = Join-Path $_.FullName "META-INF\MANIFEST.MF"
    if ((Test-Path $packInTest) -or (Test-Path $metaInfTest)) {
        $_   # has its own packin or MANIFEST — treat as a leaf plugin
    } else {
        # Parent folder — yield sub-directories
        Get-ChildItem -Path $_.FullName -Directory
    }
}

$allPluginDirs | ForEach-Object {
    $pluginDir  = $_.FullName
    $pluginName = $_.Name
    $packInDir  = Join-Path $pluginDir "migration\postgresql\packin"
    $metaInfDir = Join-Path $pluginDir "META-INF"
    $manifestF  = Join-Path $metaInfDir "MANIFEST.MF"

    if (-not (Test-Path $packInDir)) { return }

    # Skip 2Pack generation when building in Migration mode
    if ($useMigration) { return }

    # Check MANIFEST.MF has Bundle-Activator
    if (-not (Test-Path $manifestF)) {
        Write-Host "[WARNING] $pluginName has a packin/ folder but no META-INF/MANIFEST.MF — skipping." -ForegroundColor Yellow
        return
    }
    if (-not (Select-String -Path $manifestF -Pattern "Incremental2PackActivator" -Quiet)) {
        Write-Host "[WARNING] $pluginName/META-INF/MANIFEST.MF does not declare Incremental2PackActivator." -ForegroundColor Yellow
        Write-Host "          Add: Bundle-Activator: org.adempiere.plugin.utils.Incremental2PackActivator" -ForegroundColor Yellow
    }

    # Determine version: read from packin/pack-version.txt if present, else 1.0.0
    $versionFile = Join-Path $packInDir "pack-version.txt"
    $version     = if (Test-Path $versionFile) { (Get-Content $versionFile -Raw).Trim() } else { "1.0.0" }

    Write-Host "[INFO] Generating $pluginName META-INF\2Pack_$version.zip from packin/ ..." -ForegroundColor Cyan

    # Collect SQL files sorted by name
    $sqlFiles = Get-ChildItem -Path $packInDir -Filter "*.sql" | Sort-Object Name

    if ($sqlFiles.Count -eq 0) {
        Write-Host "[WARNING] $pluginName packin/ has no .sql files — skipping." -ForegroundColor Yellow
        return
    }

    # Build XML
    $now  = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $xml  = [System.Text.StringBuilder]::new()
    $total = 0
    [void]$xml.AppendLine('<?xml version="1.0" encoding="UTF-8"?>')
    [void]$xml.AppendLine("<idempiere Name=`"$pluginName`" Version=`"$version`" idempiereVersion=`"`" DataBaseVersion=`"`" Description=`"$pluginName AD Dictionary Setup`" Author=`"`" AuthorEmail=`"`" CreatedDate=`"$now`" UpdatedDate=`"$now`" PackOutVersion=`"100`" UpdateDictionary=`"false`" Client=`"0-SYSTEM-System`" AD_Client_UU=`"11237b53-9592-4af1-b3c5-afd216514b5d`">")

    foreach ($sqlFile in $sqlFiles) {
        $content    = [System.IO.File]::ReadAllText($sqlFile.FullName, [System.Text.Encoding]::UTF8)
        $statements = Split-SqlStatements -sql $content
        foreach ($stmt in $statements) {
            [void]$xml.AppendLine('    <SQLStatement type="custom">')
            [void]$xml.AppendLine('        <DBType>Postgres</DBType>')
            [void]$xml.AppendLine("        <statement><![CDATA[$stmt]]></statement>")
            [void]$xml.AppendLine('    </SQLStatement>')
            $total++
        }
    }
    [void]$xml.AppendLine('</idempiere>')

    # Remove any existing 2Pack ZIPs for this plugin (avoid version accumulation)
    Get-ChildItem -Path $metaInfDir -Filter "2Pack_*.zip" -ErrorAction SilentlyContinue | Remove-Item -Force

    # Write new ZIP
    New-Item -ItemType Directory -Force -Path $metaInfDir | Out-Null
    $zipPath    = Join-Path $metaInfDir "2Pack_$version.zip"
    $zipStream  = [System.IO.File]::Create($zipPath)
    $archive    = New-Object System.IO.Compression.ZipArchive($zipStream, [System.IO.Compression.ZipArchiveMode]::Create, $true)
    $xmlEntry   = $archive.CreateEntry("$pluginName/dict/PackOut.xml", [System.IO.Compression.CompressionLevel]::Optimal)
    $entryStream = $xmlEntry.Open()
    $writer     = New-Object System.IO.StreamWriter($entryStream, [System.Text.Encoding]::UTF8)
    $writer.Write($xml.ToString())
    $writer.Close()
    $entryStream.Close()
    $archive.Dispose()
    $zipStream.Dispose()

    Write-Host "[SUCCESS] ${pluginName}: generated META-INF\2Pack_${version}.zip ($total SQL statements)" -ForegroundColor Green
}

# 3. Run the Eclipse Tycho plugin build

Write-Host "`n[INFO] Running Maven Tycho build for plugins..." -ForegroundColor Yellow
$originalLocation = Get-Location
Set-Location $PSScriptRoot

if ($BuildTarget -eq "all") {
    if ($IsWindowsOS) { cmd /c "mvn clean verify" } else { sh -c "mvn clean verify" }
} elseif ($BuildTarget -eq "mandatory") {
    # Resolve each mandatory entry against the reactor: if not a direct module, expand to matching sub-paths
    [xml]$parentPom2 = Get-Content (Join-Path $PSScriptRoot "pom.xml")
    $reactorModules = @($parentPom2.project.modules.module)
    $resolvedModules = $mandatoryModules | ForEach-Object {
        $mod = $_
        if ($reactorModules -contains $mod) { $mod }
        else { $reactorModules | Where-Object { $_ -like "$mod/*" } }
    }
    $plList = ($resolvedModules | Where-Object { $_ }) -join ","
    Write-Host "[INFO] Building mandatory modules: $plList" -ForegroundColor Yellow
    if ($IsWindowsOS) { cmd /c "mvn clean verify -pl $plList -am" } else { sh -c "mvn clean verify -pl $plList -am" }
} else {
    $targetDir  = Join-Path $PSScriptRoot $BuildTarget
    $directPom  = Join-Path $targetDir "pom.xml"
    if (Test-Path $directPom) {
        if ($IsWindowsOS) { cmd /c "mvn clean verify -pl $BuildTarget -am" } else { sh -c "mvn clean verify -pl $BuildTarget -am" }
    } else {
        # Parent folder — build every sub-directory that has a pom.xml
        $subModules = Get-ChildItem -Path $targetDir -Directory |
            Where-Object { Test-Path (Join-Path $_.FullName "pom.xml") } |
            ForEach-Object { "$BuildTarget/$($_.Name)" }
        if (-not $subModules) {
            Write-Host "[ERROR] No buildable sub-modules found in '$BuildTarget'." -ForegroundColor Red
            Set-Location $originalLocation
            exit 1
        }
        $plList = $subModules -join ","
        Write-Host "[INFO] Building sub-modules: $plList" -ForegroundColor Yellow
        if ($IsWindowsOS) { cmd /c "mvn clean verify -pl $plList -am" } else { sh -c "mvn clean verify -pl $plList -am" }
    }
}
$exitCode = $LASTEXITCODE

if ($exitCode -ne 0) {
    Write-Host "`n[ERROR] Plugin Maven build failed with exit code $exitCode." -ForegroundColor Red
    Set-Location $originalLocation
    exit $exitCode
}

Write-Host "`n[SUCCESS] Plugin build completed successfully!" -ForegroundColor Green

# 4. Collect all built JARs into image-builder/build/ folder
$buildDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\docker-image\image-builder\build-plugins"))

# Mandatory/all mode: wipe entire build-plugins/ before collecting new artifacts
if (($BuildTarget -eq "mandatory" -or $BuildTarget -eq "all") -and (Test-Path $buildDir)) {
    Write-Host "[INFO] $($BuildTarget) mode — wiping build-plugins/ for a clean slate..." -ForegroundColor Yellow
    Remove-Item -Path $buildDir -Recurse -Force
    Write-Host "[INFO] Wiped: $buildDir" -ForegroundColor Yellow
}

New-Item -ItemType Directory -Path $buildDir -Force | Out-Null

$jarPatterns = if ($BuildTarget -eq "all") {
    @("$PSScriptRoot\*\target\*SNAPSHOT.jar", "$PSScriptRoot\*\*\target\*SNAPSHOT.jar")
} elseif ($BuildTarget -eq "mandatory") {
    $mandatoryModules | ForEach-Object { @("$PSScriptRoot\$_\target\*SNAPSHOT.jar", "$PSScriptRoot\$_\*\target\*SNAPSHOT.jar") }
} else {
    @("$PSScriptRoot\$BuildTarget\target\*SNAPSHOT.jar", "$PSScriptRoot\$BuildTarget\*\target\*SNAPSHOT.jar")
}
$pluginJars = $jarPatterns | ForEach-Object { Get-ChildItem -Path $_ -ErrorAction SilentlyContinue } |
              Sort-Object FullName -Unique
foreach ($jar in $pluginJars) {
    Write-Host "[INFO] Collecting $($jar.Name) → image-builder/build-plugins/" -ForegroundColor Cyan
    Copy-Item -Path $jar.FullName -Destination $buildDir -Force
}

Write-Host "`n[SUCCESS] All plugin JARs collected in: $buildDir" -ForegroundColor Green

# 4b. Migration mode: create plugin subfolder in build-plugins/, copy JAR, stage SQL, write run-version.txt
if ($useMigration) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue

    $targetJars = @(Get-ChildItem "$PSScriptRoot\$BuildTarget\target" -Filter "*SNAPSHOT.jar" -ErrorAction SilentlyContinue) +
                  @(Get-ChildItem "$PSScriptRoot\$BuildTarget\*\target" -Filter "*SNAPSHOT.jar" -ErrorAction SilentlyContinue)

    foreach ($builtJar in $targetJars) {
        # Read Bundle-SymbolicName from JAR manifest
        try {
            $zip   = [System.IO.Compression.ZipFile]::OpenRead($builtJar.FullName)
            $mfE   = $zip.Entries | Where-Object { $_.FullName -eq "META-INF/MANIFEST.MF" } | Select-Object -First 1
            if (-not $mfE) { $zip.Dispose(); continue }
            $rdr   = New-Object System.IO.StreamReader($mfE.Open())
            $mfTxt = $rdr.ReadToEnd(); $rdr.Close(); $zip.Dispose()
            $symName = ($mfTxt -split "`n" | Where-Object { $_ -match '^Bundle-SymbolicName:' } | Select-Object -First 1) `
                -replace 'Bundle-SymbolicName:\s*', '' -replace ';.*', '' -replace '\r', ''
            $symName = $symName.Trim()
        } catch { Write-Host "[WARNING] Could not read manifest: $($builtJar.Name)" -ForegroundColor Yellow; continue }

        if (-not $symName) { continue }

        # Create plugin subfolder and copy JAR (flat copy in build-plugins/ stays for Docker builds)
        $pluginBuildDir = Join-Path $buildDir $symName
        New-Item -ItemType Directory -Force -Path $pluginBuildDir | Out-Null
        Copy-Item -Path (Join-Path $buildDir $builtJar.Name) -Destination $pluginBuildDir -Force
        Write-Host "[INFO] Migration [$symName]: JAR → build-plugins/$symName/" -ForegroundColor Cyan

        # Read version from sql-migrations/pack-version.txt
        $srcPluginDir = $builtJar.Directory.Parent.FullName
        $verFile = Join-Path $srcPluginDir "migration\postgresql\sql-migrations\pack-version.txt"
        $ver     = if (Test-Path $verFile) { (Get-Content $verFile -Raw).Trim() } else { "1.0.0" }

        # Stage SQL from ALL version folders in sql-migrations/ — deploy decides what runs
        $srcSqlBase  = Join-Path $srcPluginDir "migration\postgresql\sql-migrations"
        $sqlDestBase = Join-Path $pluginBuildDir "sql-migrations"

        if (Test-Path $srcSqlBase) {
            $verFolders = Get-ChildItem $srcSqlBase -Directory |
                Sort-Object { try { [System.Version]$_.Name } catch { [System.Version]"0.0.0" } }
            foreach ($verDir in $verFolders) {
                $sqlDestDir = Join-Path $sqlDestBase $verDir.Name
                New-Item -ItemType Directory -Force -Path $sqlDestDir | Out-Null
                $sqlCount = 0
                Get-ChildItem $verDir.FullName -Filter "*.sql" | Sort-Object Name | ForEach-Object {
                    Copy-Item -Path $_.FullName -Destination $sqlDestDir -Force
                    $sqlCount++
                }
                Write-Host "[INFO] Migration [$symName]: staged $sqlCount SQL file(s) for v$($verDir.Name)." -ForegroundColor Cyan
            }
            if ($verFolders.Count -eq 0) {
                Write-Host "[WARNING] Migration [$symName]: no version folders found under sql-migrations/." -ForegroundColor Yellow
            }
        } else {
            Write-Host "[WARNING] Migration [$symName]: sql-migrations/ not found — skipping SQL staging." -ForegroundColor Yellow
        }

        # Write run-version.txt so deploy script knows the target version
        $ver | Set-Content (Join-Path $pluginBuildDir "run-version.txt") -NoNewline
        Write-Host "[SUCCESS] Migration [$symName]: run-version=$ver ready." -ForegroundColor Green
    }
}

# 5. Generate custom-bundles.info — merge new entries with existing ones

# Load existing entries (keyed by symbolic name) so we don't lose previously built plugins
$existingEntries = @{}
if (Test-Path $bundlesInfoPath) {
    foreach ($line in (Get-Content $bundlesInfoPath)) {
        if ($line -match '^\s*#' -or $line -match '^\s*$') { continue }
        $symName = ($line -split ',')[0].Trim()
        if ($symName) { $existingEntries[$symName] = $line }
    }
}

foreach ($jar in (Get-ChildItem $buildDir -Filter "*.jar")) {
    try {
        $zip = [System.IO.Compression.ZipFile]::OpenRead($jar.FullName)
        $manifest = $zip.Entries | Where-Object { $_.FullName -eq "META-INF/MANIFEST.MF" } | Select-Object -First 1
        if ($manifest) {
            $reader = New-Object System.IO.StreamReader($manifest.Open())
            $content = $reader.ReadToEnd()
            $reader.Close()

            $symName = ($content -split "`n" | Where-Object { $_ -match '^Bundle-SymbolicName:' } | Select-Object -First 1) -replace 'Bundle-SymbolicName:\s*', '' -replace ';.*', '' -replace '\r', ''
            $version  = ($content -split "`n" | Where-Object { $_ -match '^Bundle-Version:' }        | Select-Object -First 1) -replace 'Bundle-Version:\s*',        '' -replace '\r', ''

            if ($symName -and $version) {
                $entry = "$($symName.Trim()),$($version.Trim()),plugins/$($jar.Name),4,true"
                $existingEntries[$symName.Trim()] = $entry
                Write-Host "[INFO] bundles.info entry: $($symName.Trim())" -ForegroundColor Cyan
            }
        }
        $zip.Dispose()
    } catch {
        Write-Host "[WARNING] Could not read manifest from $($jar.Name): $_" -ForegroundColor Yellow
    }
}

$lines = @()
$lines += "# Custom plugin entries — appended to bundles.info after each fresh build"
$lines += "# Format: symbolicName,version,plugins/filename.jar,startLevel,autoStart"
$lines += "# Auto-generated by build_plugins.ps1 — do not edit manually"
$lines += ""
$lines += ($existingEntries.Values | Sort-Object)

$lines | Set-Content $bundlesInfoPath -Encoding UTF8
Write-Host "[SUCCESS] custom-bundles.info updated at: $bundlesInfoPath" -ForegroundColor Green

Set-Location $originalLocation
Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "Plugin build finished." -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green


===============================================================================================================
cr
===============================================================================================================

custom-bundles.info

# Custom plugin entries — appended to bundles.info after each fresh build
# Format: symbolicName,version,plugins/filename.jar,startLevel,autoStart
# Auto-generated by build_plugins.ps1 — do not edit manually

com.pipra.chart.dashboard,10.0.0.202606160910,plugins/com.pipra.chart.dashboard-10.0.0-SNAPSHOT.jar,4,true
com.pipra.dashboard.3dlayout,10.0.0.202606130845,plugins/com.pipra.dashboard.3dlayout-10.0.0-SNAPSHOT.jar,4,true
com.pipra.dashboard.react,10.0.0.202606090653,plugins/com.pipra.dashboard.react-10.0.0-SNAPSHOT.jar,4,true
com.pipra.mro,10.0.0.202606090656,plugins/com.pipra.mro-10.0.0-SNAPSHOT.jar,4,true
com.pipra.recruitment.ats,10.0.0.202606130813,plugins/com.pipra.recruitment.ats-10.0.0-SNAPSHOT.jar,4,true
com.trekglobal.idempiere.rest.api,10.0.0.202606090653,plugins/com.trekglobal.idempiere.rest.api-10.0.0-SNAPSHOT.jar,4,true

===============================================================================================================
cr
===============================================================================================================

PiERP_Docker_Run.sh

#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo -e "\033[36m  ██████╗ ██╗    ███████╗██████╗ ██████╗ \033[0m"
echo -e "\033[36m  ██╔══██╗██║    ██╔════╝██╔══██╗██╔══██╗\033[0m"
echo -e "\033[36m  ██████╔╝██║    █████╗  ██████╔╝██████╔╝\033[0m"
echo -e "\033[36m  ██╔═══╝ ██║    ██╔══╝  ██╔══██╗██╔═══╝ \033[0m"
echo -e "\033[36m  ██║     ██║    ███████╗██║  ██║██║     \033[0m"
echo -e "\033[36m  ╚═╝     ╚═╝    ╚══════╝╚═╝  ╚═╝╚═╝     \033[0m"
echo ""
echo -e "\033[37m  Enterprise Resource Planning — Powered by PIPRA\033[0m"
echo ""

EXISTING=$(docker compose -f "$SCRIPT_DIR/docker-compose.yml" ps -q 2>/dev/null || true)

if [ -n "$EXISTING" ]; then
    echo -e "\033[33m[INFO] Resuming stopped containers...\033[0m"
    docker compose -f "$SCRIPT_DIR/docker-compose.yml" start
else
    echo -e "\033[33m[INFO] No existing containers found — creating from image (no rebuild)...\033[0m"
    docker compose -f "$SCRIPT_DIR/docker-compose.yml" up -d
fi

# Self-healing now handled natively inside the mounted docker-entrypoint.sh

echo ""
echo -e "\033[36mWaiting for PiERP server to initialize...\033[0m"

MAX_WAIT=600
START=$(date +%s)
SERVER_UP=false
SPINNER=('-' '\' '|' '/')
i=0

printf " "
while true; do
    NOW=$(date +%s)
    ELAPSED=$((NOW - START))
    if [ $ELAPSED -ge $MAX_WAIT ]; then break; fi

    printf "\b${SPINNER[$((i % 4))]}"
    i=$((i + 1))

    STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" --max-time 2 "https://127.0.0.1/webui/" 2>/dev/null || true)
    if [ "$STATUS" = "200" ]; then
        SERVER_UP=true
        break
    fi

    sleep 1
done
printf "\b \n"

if [ "$SERVER_UP" = true ]; then
    echo ""
    echo -e "\033[32m[SUCCESS] PiERP is UP\033[0m"
    echo ""
    echo -e "\033[36m  App        : https://localhost/webui\033[0m"
    echo -e "\033[36m  OSGi       : https://localhost/osgi/system/console\033[0m"
    echo ""
    echo -e "\033[37m  Credentials\033[0m"
    echo -e "\033[90m  -----------\033[0m"
    echo -e "\033[37m  App Login  : SuperUser / System\033[0m"
    echo -e "\033[37m  Sample     : GardenAdmin / GardenAdmin\033[0m"
    echo -e "\033[37m  OSGi       : SuperUser / System\033[0m"
    echo -e "\033[37m  DB         : adempiere / adempiere  (port 5434)\033[0m"
    echo ""
    echo -e "\033[90m  Logs       : docker logs -f pi-erp-server-v10\033[0m"
    echo -e "\033[90m  Stop       : ./PiERP_Docker_Stop.sh\033[0m"
else
    echo ""
    echo -e "\033[33m[WARNING] Server did not respond within timeout. Check logs:\033[0m"
    echo -e "\033[90m  docker-compose -f \"$SCRIPT_DIR/docker-compose.yml\" logs -f\033[0m"
fi

===============================================================================================================
cr
===============================================================================================================

pom.xml

<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>com.pipra.pierp</groupId>
	<artifactId>com.pipra.pierp.r10</artifactId>
	<version>10.0.0-SNAPSHOT</version>
	<packaging>pom</packaging>

	<properties>
		<tycho.version>2.7.5</tycho.version>
		<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
	</properties>

	<modules>
		<module>com.cdsoftware.base</module>
		<module>org.globalqss.idempiere.LCO.detailednames</module>
		<module>com.cdsoftware.pluginconfig</module>
		<module>com.cdsoftware.location</module>
		<module>com.cdsoftware.payroll</module>
		<module>com.cdsoftware.attendance</module>
		<module>com.cdsoftware.employeerecruitment</module>
		<module>com.cdsoftware.employeetraining</module>
		<module>com.cdsoftware.payrollreport</module>
		<module>com.cdsoftware.performanceevaluation</module>
		<module>com.pipra.dashboard.react</module>
		<module>com.pipra.dashboard.widgets/mro</module>
		<module>com.pipra.dashboard.widgets/sales</module>
		<module>com.pipra.dashboard.widgets/chatbot</module>
		<module>com.pipra.chart.dashboard</module>
		<module>com.pipra.dashboard.3dlayout</module>
		<module>org.asset.maintenance</module>
		<module>com.pipra.mro</module>
		<module>com.pipra.piedge</module>
		<module>idempiere-rest/com.trekglobal.idempiere.rest.api</module>
		<module>com.pipra.unauth.events</module>
		<module>com.pipra.recruitment.ats</module>
	</modules>

	<repositories>
		<repository>
			<id>pierp-core-local-p2</id>
			<layout>p2</layout>
			<url>file:../core/pi-erp-core/idempiere-release-10/org.idempiere.p2/target/repository</url>
		</repository>
	</repositories>

	<build>
		<plugins>
			<plugin>
				<groupId>org.eclipse.tycho</groupId>
				<artifactId>tycho-maven-plugin</artifactId>
				<version>${tycho.version}</version>
				<extensions>true</extensions>
			</plugin>
			<plugin>
				<groupId>org.eclipse.tycho</groupId>
				<artifactId>target-platform-configuration</artifactId>
				<version>${tycho.version}</version>
				<configuration>
					<executionEnvironmentDefault>JavaSE-11</executionEnvironmentDefault>
					<executionEnvironment>JavaSE-11</executionEnvironment>
					<environments>
						<environment>
							<os>win32</os>
							<ws>win32</ws>
							<arch>x86_64</arch>
						</environment>
					</environments>
				</configuration>
			</plugin>
		</plugins>
	</build>
</project>

===============================================================================================================
cr
===============================================================================================================

PiERP_Docker_Stop.sh

#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================================="
echo "        PiERP - Docker Stop"
echo "=========================================================="
echo ""
echo -e "\033[33mStopping containers...\033[0m"

docker compose -f "$SCRIPT_DIR/docker-compose.yml" stop

echo ""
echo "=========================================================="
echo -e "\033[32mDocker Containers Stopped.\033[0m"
echo "=========================================================="


===============================================================================================================
cr
===============================================================================================================

PiERP_Deploy_DockerHub.sh

#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo -e "\033[36m  ██████╗ ██╗    ███████╗██████╗ ██████╗ \033[0m"
echo -e "\033[36m  ██╔══██╗██║    ██╔════╝██╔══██╗██╔══██╗\033[0m"
echo -e "\033[36m  ██████╔╝██║    █████╗  ██████╔╝██████╔╝\033[0m"
echo -e "\033[36m  ██╔═══╝ ██║    ██╔══╝  ██╔══██╗██╔═══╝ \033[0m"
echo -e "\033[36m  ██║     ██║    ███████╗██║  ██║██║     \033[0m"
echo -e "\033[36m  ╚═╝     ╚═╝    ╚══════╝╚═╝  ╚═╝╚═╝     \033[0m"
echo ""
echo -e "\033[37m  Deploy from Docker Hub — pipradock\033[0m"
echo ""

DOCKER_ORG="pipradock"
SERVER_IMAGE="$DOCKER_ORG/pi-erp-server-v10:latest"
DB_IMAGE="$DOCKER_ORG/pi-erp-db-v10:latest"
COMPOSE="$SCRIPT_DIR/docker-compose.yml"

# [1/2] Pull images from Docker Hub
echo -e "\033[33m[1/2] Pulling images from Docker Hub...\033[0m"
echo -e "\033[90m      $DB_IMAGE\033[0m"
echo -e "\033[90m      $SERVER_IMAGE\033[0m"
docker compose -f "$COMPOSE" pull
if [ $? -ne 0 ]; then
    echo -e "\033[31m[ERROR] Failed to pull images.\033[0m"
    exit 1
fi

# [2/2] Start containers
echo ""
echo -e "\033[33m[2/2] Starting containers...\033[0m"
docker compose -f "$COMPOSE" up -d
if [ $? -ne 0 ]; then
    echo -e "\033[31m[ERROR] docker-compose failed to start.\033[0m"
    exit 1
fi

echo ""
echo -e "\033[36mWaiting for PiERP to initialize...\033[0m"

MAX_WAIT=300
START=$(date +%s)
SERVER_UP=false
SPINNER=('-' '\' '|' '/')
i=0

printf " "
while true; do
    NOW=$(date +%s)
    ELAPSED=$((NOW - START))
    if [ $ELAPSED -ge $MAX_WAIT ]; then break; fi

    printf "\b${SPINNER[$((i % 4))]}"
    i=$((i + 1))

    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 "http://127.0.0.1:8080/webui/" 2>/dev/null || true)
    if [ "$STATUS" = "200" ]; then
        SERVER_UP=true
        break
    fi

    sleep 1
done
printf "\b \n"

if [ "$SERVER_UP" = true ]; then
    echo ""
    echo -e "\033[32m[SUCCESS] PiERP is UP — All plugins pre-installed and ready.\033[0m"
    echo ""
    echo -e "\033[36m  App        : https://localhost:8443/webui\033[0m"
    echo -e "\033[36m  OSGi       : https://localhost:8443/osgi/system/console\033[0m"
    echo ""
    echo -e "\033[37m  Credentials\033[0m"
    echo -e "\033[90m  -----------\033[0m"
    echo -e "\033[37m  App Login  : SuperUser / System\033[0m"
    echo -e "\033[37m  Sample     : GardenAdmin / GardenAdmin\033[0m"
    echo -e "\033[37m  OSGi       : SuperUser / System\033[0m"
    echo -e "\033[37m  DB         : adempiere / adempiere  (port 5434)\033[0m"
    echo ""
    echo -e "\033[90m  Logs       : docker logs -f pi-erp-server-v10\033[0m"
    echo -e "\033[90m  Stop       : ./PiERP_Docker_Stop.sh\033[0m"
else
    echo ""
    echo -e "\033[33m[WARNING] Server did not respond within timeout. Check logs:\033[0m"
    echo -e "\033[90m  docker-compose -f \"$COMPOSE\" logs -f\033[0m"
fi
