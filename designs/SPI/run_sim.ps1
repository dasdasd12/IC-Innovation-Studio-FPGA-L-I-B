param(
    [string]$tb = "tb/spi_tb.v",
    [string]$srcs = "src",
    [string]$out = "icarus/spi_tb.vvp",
    [string]$vcd = "icarus/spi_tb.vcd",
    [string]$gtkwavePath = "gtkwave"
)

$ErrorActionPreference = 'Stop'

# Resolve source files (recursively if directory)
if (Test-Path $srcs -PathType Container) {
    $srcFiles = Get-ChildItem -Path $srcs -Recurse -Filter "*.v" | Select-Object -ExpandProperty FullName
} else {
    $srcFiles = Resolve-Path $srcs | Select-Object -ExpandProperty Path
}

Write-Host "Compiling: iverilog -o $out $tb $srcFiles"
& iverilog -o $out $tb $srcFiles
if ($LASTEXITCODE -ne 0) { Write-Error "iverilog failed (exit $LASTEXITCODE)"; exit $LASTEXITCODE }

Write-Host "Running: vvp $out"
& vvp $out
if ($LASTEXITCODE -ne 0) { Write-Error "vvp failed (exit $LASTEXITCODE)"; exit $LASTEXITCODE }

if (Test-Path $vcd) {
    Write-Host "VCD created: $vcd"
    try {
        Write-Host "Opening GTKWave (path: $gtkwavePath)"
        Start-Process -FilePath $gtkwavePath -ArgumentList $vcd -ErrorAction Stop
    } catch {
        Write-Warning "Failed to start GTKWave. You can open $vcd manually with GTKWave."
        Write-Host "If GTKWave is installed, provide its full path: .\\run_sim.ps1 -gtkwavePath 'C:\\Program Files\\gtkwave\\gtkwave.exe'"
    }
} else {
    Write-Warning "VCD not found: $vcd"
}
