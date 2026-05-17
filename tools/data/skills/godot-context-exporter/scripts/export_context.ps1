# export_context.ps1
# Automates the Sovereign Context Export for Ashen Oath

$GODOT_PATH = "C:\Users\Chris\Godot_4.6\godot.exe"
$SCRIPT_PATH = "scripts/tools/ContextExport.gd"

Write-Host "PHOENIX-AGENT: Triggering Deep Context Synthesis..." -ForegroundColor Cyan

if (Test-Path $GODOT_PATH) {
	& $GODOT_PATH --headless -s $SCRIPT_PATH
	if ($LASTEXITCODE -eq 0) {
		Write-Host "PHOENIX-AGENT: Synthesis Complete -> context_export.txt" -ForegroundColor Green
	}
 else {
		Write-Host "PHOENIX-AGENT: Synthesis Failed with Exit Code $LASTEXITCODE" -ForegroundColor Red
	}
}
else {
	Write-Host "PHOENIX-AGENT: ERROR - Godot executable not found at $GODOT_PATH" -ForegroundColor Red
}
