# FasterAgent Installer for Windows (PowerShell)
[CmdletBinding(DefaultParameterSetName = "Default")]
param(
    [Parameter(ParameterSetName = "Global")]
    [switch]$Global,

    [Parameter(ParameterSetName = "Local")]
    [switch]$Local,

    [Parameter(ParameterSetName = "Local")]
    [string]$TargetDir = ""
)

$ErrorActionPreference = "Stop"

# If neither is explicitly chosen, default to Global installation
if (-not $Local -and -not $Global) {
    $Global = $true
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$RootDir = Split-Path -Parent $ScriptDir

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   ⚡ FasterAgent Installer for Antigravity" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Global Installation to ~/.gemini/config
if ($Global) {
    $UserProfile = [System.Environment]::GetFolderPath('UserProfile')
    $GeminiConfigDir = Join-Path $UserProfile ".gemini\config"
    $GlobalRulesDir = Join-Path $GeminiConfigDir "rules"
    $GlobalSkillsDir = Join-Path $GeminiConfigDir "skills\faster-agent"

    Write-Host "[+] Installing FasterAgent globally to: $GeminiConfigDir" -ForegroundColor Green

    if (-not (Test-Path $GlobalRulesDir)) {
        New-Item -ItemType Directory -Path $GlobalRulesDir -Force | Out-Null
    }
    if (-not (Test-Path $GlobalSkillsDir)) {
        New-Item -ItemType Directory -Path $GlobalSkillsDir -Force | Out-Null
    }

    $SourceRule = Join-Path $RootDir "rules\faster-agent.md"
    $DestRule = Join-Path $GlobalRulesDir "faster-agent.md"
    Copy-Item -Path $SourceRule -Destination $DestRule -Force
    Write-Host "  -> Installed rule: $DestRule" -ForegroundColor Gray

    $SourceSkill = Join-Path $RootDir "skills\faster-agent\SKILL.md"
    $DestSkill = Join-Path $GlobalSkillsDir "SKILL.md"
    Copy-Item -Path $SourceSkill -Destination $DestSkill -Force
    Write-Host "  -> Installed skill: $DestSkill" -ForegroundColor Gray

    Write-Host "`n[PASS] Global FasterAgent configuration active across all Antigravity sessions!" -ForegroundColor Green
}

# 2. Local Installation to specific project workspace
if ($Local) {
    if ([string]::IsNullOrWhiteSpace($TargetDir)) {
        $TargetDir = (Get-Location).Path
    }

    Write-Host "`n[+] Installing FasterAgent locally to workspace: $TargetDir" -ForegroundColor Green

    $LocalAgentsRulesDir = Join-Path $TargetDir ".agents\rules"
    if (-not (Test-Path $LocalAgentsRulesDir)) {
        New-Item -ItemType Directory -Path $LocalAgentsRulesDir -Force | Out-Null
    }

    # Copy GEMINI.md to project root
    $SourceGemini = Join-Path $RootDir "rules\GEMINI.md"
    $DestGemini = Join-Path $TargetDir "GEMINI.md"
    Copy-Item -Path $SourceGemini -Destination $DestGemini -Force
    Write-Host "  -> Copied GEMINI.md to workspace root: $DestGemini" -ForegroundColor Gray

    # Copy AGENTS.md to project root
    $SourceAgents = Join-Path $RootDir "rules\AGENTS.md"
    $DestAgents = Join-Path $TargetDir "AGENTS.md"
    Copy-Item -Path $SourceAgents -Destination $DestAgents -Force
    Write-Host "  -> Copied AGENTS.md to workspace root: $DestAgents" -ForegroundColor Gray

    # Copy faster-agent.md to .agents/rules/
    $SourceRule = Join-Path $RootDir "rules\faster-agent.md"
    $DestLocalRule = Join-Path $LocalAgentsRulesDir "faster-agent.md"
    Copy-Item -Path $SourceRule -Destination $DestLocalRule -Force
    Write-Host "  -> Copied rule to .agents/rules/faster-agent.md" -ForegroundColor Gray

    Write-Host "`n[PASS] Workspace FasterAgent rules applied to: $TargetDir" -ForegroundColor Green
}

Write-Host "`nFasterAgent is ready! High-velocity execution and surgical testing are now enabled." -ForegroundColor Cyan
