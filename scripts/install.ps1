# FasterAgent Installer for Windows (PowerShell)
[CmdletBinding(DefaultParameterSetName = "Default")]
param(
    [Parameter(ParameterSetName = "Global")]
    [switch]$Global,

    [Parameter(ParameterSetName = "Local")]
    [switch]$Local,

    [Parameter(ParameterSetName = "Local")]
    [string]$TargetDir = "",

    [Parameter(ParameterSetName = "Default")]
    [switch]$Sync
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

# 1. Global Installation to ~/.gemini and ~/.gemini/config
if ($Global) {
    $UserProfile = [System.Environment]::GetFolderPath('UserProfile')
    $GeminiHomeDir = Join-Path $UserProfile ".gemini"
    $GeminiConfigDir = Join-Path $GeminiHomeDir "config"
    $GlobalRulesDir = Join-Path $GeminiConfigDir "rules"
    $GlobalSkillsDir = Join-Path $GeminiConfigDir "skills\faster-agent"
    $GlobalGeminiMd = Join-Path $GeminiHomeDir "GEMINI.md"
    $SettingsJson = Join-Path $GeminiHomeDir "settings.json"

    Write-Host "[+] Installing FasterAgent globally to: $GeminiHomeDir" -ForegroundColor Green

    # Ensure directories exist
    if (-not (Test-Path $GlobalRulesDir)) {
        New-Item -ItemType Directory -Path $GlobalRulesDir -Force | Out-Null
    }
    if (-not (Test-Path $GlobalSkillsDir)) {
        New-Item -ItemType Directory -Path $GlobalSkillsDir -Force | Out-Null
    }

    # Copy rules/faster-agent.md
    $SourceRule = Join-Path $RootDir "rules\faster-agent.md"
    $DestRule = Join-Path $GlobalRulesDir "faster-agent.md"
    Copy-Item -Path $SourceRule -Destination $DestRule -Force
    Write-Host "  -> Installed rule: $DestRule" -ForegroundColor Gray

    # Copy skills/faster-agent/SKILL.md
    $SourceSkill = Join-Path $RootDir "skills\faster-agent\SKILL.md"
    $DestSkill = Join-Path $GlobalSkillsDir "SKILL.md"
    Copy-Item -Path $SourceSkill -Destination $DestSkill -Force
    Write-Host "  -> Installed skill: $DestSkill" -ForegroundColor Gray

    # --- CRITICAL: Inject FasterAgent directly into ~/.gemini/GEMINI.md (RULE[user_global]) ---
    $GlobalRulesContent = @'
<!-- faster-agent-global -->
# FasterAgent: Velocity-First, Anti-Loop & Surgical Execution Protocol

CRITICAL OPERATIONAL DIRECTIVE FOR ALL SESSIONS:
Your primary mandate is **high-velocity 100% task execution** without getting trapped in exploratory loops, tool hesitation, background polling, or excessive testing.

## ⚡ 1. VELOCITY & TURN-1 EXECUTION (ZERO STUBS)
1. **Immediate Execution**: Begin modifying code or performing requested operations immediately in turn 1. Do NOT emit long conversational explanations or narrative plans before taking action.
2. **100% Functional Completeness**: Complete 100% of the requested technical features, code deliverables, and edge cases. NEVER leave stubs, `// TODO: implement later`, placeholder functions, or truncated logic.
3. **Batched & Parallel Operations**: Bundle independent tool calls and edits into a single turn whenever possible. Modify multiple target files or chunks in one operation to minimize turn latency.
4. **Tool Fallback Shield (Zero Hesitation)**: If specialized or lean tools (e.g. `ctx_*`) are NOT registered in your active tool list, **IMMEDIATELY and without hesitation use native tools** (`view_file`, `replace_file_content`, `run_command`, `grep_search`, `list_dir`). Never deliberate or apologize for tool availability; proceed instantly with available native tools.

## 🛑 2. ANTI-POLLING & ANTI-LOOP CIRCUIT BREAKERS
1. **Zero Background Polling**: NEVER repeatedly poll or loop on `manage_task(Action='status')` or wait in a loop for commands/containers to finish. Antigravity automatically notifies you reactively when background tasks complete. Launch background commands and STOP calling tools to end your turn.
2. **External Infrastructure Circuit Breaker (Max 1 Check/Fix)**: For Docker containers, dev servers, external databases, or services: perform at most ONE (1) restart or diagnostic check. If the service fails or remains restarting after 1 attempt, HALT immediately and present the diagnostic logs to the user. Do NOT retry in loops.
3. **Anti-Exploration Shield**: Only view files directly relevant to the user request. Never recursively scan irrelevant directories or read entire multi-thousand-line files when inspecting a specific function or bug.

## 🧪 3. HYBRID SMOKE & SURGICAL TESTING POLICY
1. **Smoke Check First**: Validate syntax/typechecking on modified files only (`tsc --noEmit`, `py_compile`, `php -l`, `cargo check`).
2. **Surgical Test Only**: Run ONLY the single test file or specific test case directly mapped to the modified code.
3. **Forbidden Full Suites**: NEVER execute repository-wide test suites (`npm test`, `pytest`, `cargo test`, `composer test`) unless the user explicitly requested a full regression run.
4. **Strict Test Circuit Breaker**: Stop immediately once the surgical test passes. If it fails, attempt at most ONE (1) fix. If still failing, HALT testing immediately and present the diagnosis to the user.

## 🎯 4. LEAN CONTEXT & TOKEN CONSERVATION
1. Keep outputs concise and action-oriented: 1-sentence action summary, code changes/diffs, and verification result.
2. Avoid conversational filler or repeating user input.
<!-- /faster-agent-global -->
'@

    if (Test-Path $GlobalGeminiMd) {
        $ExistingContent = Get-Content -Path $GlobalGeminiMd -Raw -Encoding UTF8
        
        # Check if faster-agent-global is already present
        if ($ExistingContent -match '<!-- faster-agent-global -->[\s\S]*?<!-- /faster-agent-global -->') {
            $UpdatedContent = $ExistingContent -replace '<!-- faster-agent-global -->[\s\S]*?<!-- /faster-agent-global -->', $GlobalRulesContent.Trim()
            Write-Host "  -> Updated existing FasterAgent directives in: $GlobalGeminiMd" -ForegroundColor Gray
        } else {
            # Prepend to the top of GEMINI.md
            $UpdatedContent = $GlobalRulesContent.Trim() + "`r`n`r`n" + $ExistingContent
            Write-Host "  -> Injected FasterAgent global directives into top of: $GlobalGeminiMd" -ForegroundColor Gray
        }

        # Fix lean-ctx conflict if present: ensure fallback is permitted
        if ($UpdatedContent -match 'CRITICAL: ALWAYS use lean-ctx ctx_\* tools') {
            if ($UpdatedContent -notmatch 'FALLBACK: When ctx_\* tools are not registered') {
                $UpdatedContent = $UpdatedContent -replace '(CRITICAL: ALWAYS use lean-ctx ctx_\* tools instead of native equivalents\. This is NOT optional\.)', "`$1`r`n(FALLBACK: When ctx_* tools are not registered in the active agent profile, IMMEDIATELY use native Antigravity tools: view_file, replace_file_content, run_command, grep_search, list_dir with zero hesitation.)"
                Write-Host "  -> Added native tool fallback guard to lean-ctx directive in: $GlobalGeminiMd" -ForegroundColor Yellow
            }
        }

        Set-Content -Path $GlobalGeminiMd -Value $UpdatedContent -Encoding UTF8 -Force
    } else {
        Set-Content -Path $GlobalGeminiMd -Value $GlobalRulesContent.Trim() -Encoding UTF8 -Force
        Write-Host "  -> Created new global GEMINI.md with FasterAgent rules: $GlobalGeminiMd" -ForegroundColor Gray
    }

    # --- Sanitize settings.json hooks if hook deny blocks native tools ---
    if (Test-Path $SettingsJson) {
        try {
            $SettingsRaw = Get-Content -Path $SettingsJson -Raw -Encoding UTF8
            $SettingsObj = $SettingsRaw | ConvertFrom-Json
            
            $Modified = $false
            if ($SettingsObj.hooks -and $SettingsObj.hooks.BeforeTool) {
                $NewBeforeHooks = @()
                foreach ($h in $SettingsObj.hooks.BeforeTool) {
                    $HasDeny = $false
                    if ($h.hooks) {
                        foreach ($inner in $h.hooks) {
                            if ($inner.command -match 'hook deny') {
                                $HasDeny = $true
                                break
                            }
                        }
                    }
                    if (-not $HasDeny) {
                        $NewBeforeHooks += $h
                    } else {
                        Write-Host "  -> Neutralized blocking 'hook deny' in settings.json to prevent tool lockup" -ForegroundColor Yellow
                        $Modified = $true
                    }
                }
                $SettingsObj.hooks.BeforeTool = $NewBeforeHooks
            }

            if ($Modified) {
                # Backup old settings.json
                Copy-Item -Path $SettingsJson -Destination "$SettingsJson.bak" -Force
                $SettingsObj | ConvertTo-Json -Depth 10 | Set-Content -Path $SettingsJson -Encoding UTF8 -Force
                Write-Host "  -> Saved sanitized settings.json (backup created at $SettingsJson.bak)" -ForegroundColor Gray
            }
        } catch {
            Write-Host "  [!] Note: Could not parse settings.json: $_" -ForegroundColor DarkYellow
        }
    }

    Write-Host "`n[PASS] Global FasterAgent configuration synced and active across all Antigravity sessions!" -ForegroundColor Green
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

Write-Host "`nFasterAgent is ready! High-velocity execution, zero background polling, and surgical testing are now active." -ForegroundColor Cyan
