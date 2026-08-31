Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$AppName = "MapleSkills"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VersionFile = Join-Path $ScriptDir "VERSION.txt"
$AppVersion = if (Test-Path $VersionFile) { (Get-Content $VersionFile -Raw).Trim() } else { "UNKNOWN" }

# ============================================================
# KISS UI
# Pick Character
# Pick Level
# Generate ALL available skill trees
# ============================================================

function New-SkillDef {
    param(
        [string]$Id,
        [string]$SkillName,
        [int]$UnlockLevel,
        [string]$SkillCategory,
        [string]$BasicAttackGroup = "",
        [string[]]$CommunityAliases = @(),
        [string]$TimingRole = "NORMAL"
    )
    [pscustomobject]@{
        Id=$Id
        SkillName=$SkillName
        UnlockLevel=$UnlockLevel
        SkillCategory=$SkillCategory
        BasicAttackGroup=$BasicAttackGroup
        CommunityAliases=$CommunityAliases
        TimingRole=$TimingRole
    }
}

function New-Template {
    param(
        [string]$Id,
        [string]$Label,
        [string[]]$OrderedSkills,
        [string]$PresetStatus="COMMUNITY_DERIVED",
        [string]$Notes=""
    )
    [pscustomobject]@{
        Id=$Id
        Label=$Label
        OrderedSkills=$OrderedSkills
        PresetStatus=$PresetStatus
        Notes=$Notes
    }
}

function New-Scenario {
    param(
        [string]$ScenarioId,
        [string]$ScenarioName,
        [string]$Category,
        [string]$AvailabilityType,
        [bool]$CurrentlyLive,
        [string]$RecommendedTemplate,
        [bool]$RequiresSkillPreset=$true,
        [string]$PresetStatus="COMMUNITY_DERIVED",
        [string]$MechanicProfile="",
        [string]$Notes=""
    )
    [pscustomobject]@{
        ScenarioId=$ScenarioId
        ScenarioName=$ScenarioName
        Category=$Category
        AvailabilityType=$AvailabilityType
        CurrentlyLive=$CurrentlyLive
        RecommendedTemplate=$RecommendedTemplate
        RequiresSkillPreset=$RequiresSkillPreset
        PresetStatus=$PresetStatus
        MechanicProfile=$MechanicProfile
        Notes=$Notes
    }
}

# ------------------------------------------------------------
# I/L Mage clean Lv110 data
# ------------------------------------------------------------

$ILSkills = @(
    (New-SkillDef "magic_guard" "Magic Guard" 15 "Defensive"),
    (New-SkillDef "frozen_orb" "Frozen Orb" 107 "Ice Damage" "" @() "ICE_SETUP"),
    (New-SkillDef "freezing_breath" "Freezing Breath" 103 "Control/Burst" "" @() "BOSS_TIMING_SENSITIVE"),
    (New-SkillDef "chain_lightning" "Chain Lightning" 100 "Basic Attack" "BASIC_ATTACK" @() "LIGHTNING_PAYOFF"),
    (New-SkillDef "frost_ward" "Frost Ward" 63 "Defensive/Utility" "" @("Glacier Wall") "UTILITY"),
    (New-SkillDef "blizzard" "Blizzard" 105 "Burst/Ice" "" @() "ICE_SETUP"),
    (New-SkillDef "meditation" "Meditation" 40 "Buff" "" @() "BUFF_BEFORE_DAMAGE"),
    (New-SkillDef "thunder_bolt" "Thunder Bolt" 38 "Damage"),
    (New-SkillDef "thunder_sphere" "Thunder Sphere" 69 "Damage"),
    (New-SkillDef "teleport" "Teleport" 10 "Movement" "" @() "MOVEMENT_FIRST"),
    (New-SkillDef "nimble_feet" "Nimble Feet" 1 "Movement" "" @() "MOVEMENT"),
    (New-SkillDef "infinity" "Infinity" 110 "Buff" "" @() "BUFF_BEFORE_BURST")
)

$ILSkillByName = @{}
foreach($s in $ILSkills) {
    $ILSkillByName[$s.SkillName] = $s
    foreach($a in $s.CommunityAliases) { $ILSkillByName[$a] = $s }
}

$ILTemplates110 = @{
    "HUNT_FARMING" = New-Template "HUNT_FARMING" "HUNT / FARMING" @(
        "Teleport","Meditation","Infinity","Nimble Feet","Blizzard","Frozen Orb",
        "Freezing Breath","Thunder Sphere","Frost Ward","Chain Lightning","Magic Guard","Thunder Bolt"
    ) "COMMUNITY_DERIVED - LV110"

    "BREAKTHROUGH" = New-Template "BREAKTHROUGH" "CHAPTER BREAKTHROUGH" @(
        "Blizzard","Infinity","Meditation","Frozen Orb","Freezing Breath","Chain Lightning",
        "Nimble Feet","Thunder Sphere","Frost Ward","Magic Guard","Thunder Bolt","Teleport"
    ) "COMMUNITY_DERIVED - LV110" "Freezing Breath is timing-sensitive."

    "DIRECT_BOSS" = New-Template "DIRECT_BOSS" "DIRECT BOSS" @(
        "Blizzard","Infinity","Meditation","Frozen Orb","Freezing Breath","Chain Lightning",
        "Frost Ward","Thunder Sphere","Magic Guard","Nimble Feet","Thunder Bolt","Teleport"
    ) "COMMUNITY_DERIVED - LV110"

    "MIXED_PVE" = New-Template "MIXED_PVE" "MIXED PVE" @(
        "Blizzard","Infinity","Meditation","Frozen Orb","Freezing Breath","Chain Lightning",
        "Nimble Feet","Teleport","Thunder Sphere","Frost Ward","Magic Guard","Thunder Bolt"
    ) "COMMUNITY_DERIVED - LV110"

    "MOVEMENT_BOSS" = New-Template "MOVEMENT_BOSS" "MOVEMENT BOSS" @(
        "Teleport","Blizzard","Infinity","Meditation","Frozen Orb","Freezing Breath",
        "Chain Lightning","Frost Ward","Thunder Sphere","Magic Guard","Nimble Feet","Thunder Bolt"
    ) "COMMUNITY_DERIVED - LV110"

    "PVP" = New-Template "PVP" "PVP" @(
        "Meditation","Magic Guard","Nimble Feet","Frost Ward","Freezing Breath","Frozen Orb",
        "Chain Lightning","Infinity","Thunder Sphere","Blizzard","Thunder Bolt","Teleport"
    ) "COMMUNITY_DERIVED - LV110" "Meditation before Nimble Feet is intentional because buff removal matters."

    "GUILD_RAID_ZAKUM" = New-Template "GUILD_RAID_ZAKUM" "GUILD RAID ZAKUM / SURVIVAL BOSS" @(
        "Magic Guard","Meditation","Infinity","Frost Ward","Blizzard","Frozen Orb",
        "Freezing Breath","Chain Lightning","Thunder Sphere","Nimble Feet","Thunder Bolt","Teleport"
    ) "COMMUNITY_DERIVED - LV110"
}

$ILScenarios = @(
    (New-Scenario "chapter_hunt" "Chapter Hunt" "Chapter" "PERMANENT" $true "HUNT_FARMING"),
    (New-Scenario "chapter_breakthrough" "Chapter Breakthrough" "Chapter" "PERMANENT" $true "BREAKTHROUGH"),
    (New-Scenario "chapter_boss" "Chapter Boss" "Chapter" "PERMANENT" $true "DIRECT_BOSS"),

    (New-Scenario "growth_weapon" "Weapon Dungeon" "Growth Dungeon" "PERMANENT" $true "DIRECT_BOSS"),
    (New-Scenario "growth_exp" "EXP Dungeon" "Growth Dungeon" "PERMANENT" $true "HUNT_FARMING"),
    (New-Scenario "growth_equipment" "Equipment Dungeon" "Growth Dungeon" "PERMANENT" $true "HUNT_FARMING"),
    (New-Scenario "growth_hero_training" "Hero Training Ground" "Growth Dungeon" "PERMANENT" $true "MIXED_PVE"),
    (New-Scenario "growth_enhancement" "Enhancement Dungeon" "Growth Dungeon" "PERMANENT" $true "MOVEMENT_BOSS"),

    (New-Scenario "world_boss" "World Boss" "World Boss" "PERMANENT" $true "DIRECT_BOSS"),

    (New-Scenario "pq_first_time_together" "First Time Together" "Party Quest" "PERMANENT" $true "HUNT_FARMING"),
    (New-Scenario "pq_dimensional_crack" "Dimensional Crack" "Party Quest" "PERMANENT" $true "MIXED_PVE"),
    (New-Scenario "pq_remnant_goddess" "Remnant of the Goddess" "Party Quest" "PERMANENT" $true "DIRECT_BOSS"),
    (New-Scenario "pq_romeo_juliet" "Romeo and Juliet" "Party Quest" "PERMANENT" $true "MIXED_PVE"),

    (New-Scenario "arena" "Arena" "PvP" "PERMANENT" $true "PVP"),

    (New-Scenario "guild_conquest" "Guild Conquest" "Guild" "PERMANENT" $true "DIRECT_BOSS"),
    (New-Scenario "guild_boss_battle" "Guild Boss Battle" "Guild" "PERMANENT" $true "DIRECT_BOSS"),
    (New-Scenario "guild_raid_zakum" "Guild Raid: Zakum" "Guild" "PERMANENT" $true "GUILD_RAID_ZAKUM"),

    (New-Scenario "boss_raid_zakum" "Boss Raid: Zakum" "Boss Raid" "PERMANENT" $true "DIRECT_BOSS"),
    (New-Scenario "boss_raid_horntail" "Boss Raid: Horntail" "Boss Raid" "PERMANENT" $true "DIRECT_BOSS"),

    (New-Scenario "colosseum" "Colosseum" "PvP" "PERMANENT" $true "PVP"),

    (New-Scenario "star_force_hunting_zone" "Star Force Hunting Zone" "Event / Hunting" "ROTATING" $false "HUNT_FARMING" $true "COMMUNITY_DERIVED - LV110" "Farming" "Preset remains available while inactive."),
    (New-Scenario "world_arena" "World Arena" "PvP" "ROTATING" $false "PVP" $true "COMMUNITY_DERIVED - LV110" "PvP" "Derived PvP mapping."),
    (New-Scenario "guild_training_ground" "Guild Training Ground" "Guild / Rotating" "ROTATING" $false "MIXED_PVE" $true "COMMUNITY_DERIVED - LV110" "Mass normal-monster / escalating-wave PvE" "Dedicated scenario identity; not Guild Raid.")
)

$ValidationHistory = @{
    "chapter_breakthrough" = @(
        [pscustomobject]@{ Result="Boss remaining 7%"; Date="2026-09-01"; Label="Fresh Lv110 community-derived build" },
        [pscustomobject]@{ Result="Boss remaining 8%"; Date="OLDER"; Label="Older custom build" },
        [pscustomobject]@{ Result="Clear"; Date="OLDER"; Label="Earlier community-oriented build" }
    )
}

# ------------------------------------------------------------
# Other classes
# ------------------------------------------------------------
# Keep them visible. Until their new template systems are populated,
# the report says COMMUNITY DATA UPDATE REQUIRED instead of inventing builds.

$Classes = @(
    "Arch Mage (Ice/Lightning)",
    "Arch Mage (Fire/Poison)",
    "Bishop",
    "Hero",
    "Paladin",
    "Dark Knight",
    "Bowmaster",
    "Marksman",
    "Night Lord",
    "Shadower",
    "Buccaneer",
    "Corsair",
    "Night Walker",
    "Wind Archer"
)

function Get-AvailableILSkills([int]$Level) {
    return @($ILSkills | Where-Object { $_.UnlockLevel -le $Level })
}

function Get-ILTemplateForLevel([string]$TemplateId,[int]$Level) {
    if (-not $ILTemplates110.ContainsKey($TemplateId)) {
        throw "Unknown template: $TemplateId"
    }

    # Exact clean template work is currently established for Lv110.
    # For other levels, use only unlocked skills and preserve source order.
    $template = $ILTemplates110[$TemplateId]
    $availableNames = @((Get-AvailableILSkills $Level) | Select-Object -ExpandProperty SkillName)

    $ordered = New-Object System.Collections.Generic.List[string]
    foreach($name in $template.OrderedSkills) {
        if ($availableNames -contains $name) {
            $ordered.Add($name)
        }
    }

    # Do not invent unavailable future skills.
    # Do not add conflicting obsolete Basic Attacks as filler.
    $status = if ($Level -eq 110) { $template.PresetStatus } else { "COMMUNITY_DERIVED - LEVEL $Level" }

    [pscustomobject]@{
        Id=$template.Id
        Label=$template.Label
        OrderedSkills=$ordered.ToArray()
        PresetStatus=$status
        Notes=$template.Notes
    }
}

function Test-ILPreset([object[]]$Entries,[int]$Level) {
    $issues = New-Object System.Collections.Generic.List[string]

    $basics = @($Entries | Where-Object { $_.BasicAttackGroup -eq "BASIC_ATTACK" })
    if ($Level -ge 100) {
        if ($basics.Count -ne 1 -or $basics[0].SkillName -ne "Chain Lightning") {
            $issues.Add("Chain Lightning must be the only active Basic Attack.")
        }
    }

    if (@($Entries | Where-Object { $_.UnlockLevel -gt $Level }).Count -gt 0) {
        $issues.Add("Locked skill found.")
    }

    if (@($Entries | Where-Object { $_.SkillName -eq "Glacier Wall" }).Count -gt 0) {
        $issues.Add("Obsolete player-facing name found.")
    }

    return $issues.ToArray()
}

function Make-ILReport([int]$Level) {
    $lines = New-Object System.Collections.Generic.List[string]

    $lines.Add("MAPLESTORY IDLE RPG - MAPLESKILLS")
    $lines.Add("MapleSkills v$AppVersion")
    $lines.Add("Class: Arch Mage (Ice/Lightning)")
    $lines.Add("Character level: $Level")
    $lines.Add("")
    $lines.Add("ALL AVAILABLE SKILL TREES")
    $lines.Add("")

    foreach($scenario in $ILScenarios) {
        if (-not $scenario.RequiresSkillPreset) { continue }

        $template = Get-ILTemplateForLevel $scenario.RecommendedTemplate $Level
        $entries = New-Object System.Collections.Generic.List[object]
        $slot = 1

        foreach($name in $template.OrderedSkills) {
            if (-not $ILSkillByName.ContainsKey($name)) { continue }
            $s = $ILSkillByName[$name]

            $entries.Add([pscustomobject]@{
                SkillId=$s.Id
                SkillName=$s.SkillName
                Slot=$slot
                Equipped=$true
                AutoUse="UNKNOWN"
                UnlockLevel=$s.UnlockLevel
                SkillCategory=$s.SkillCategory
                BasicAttackGroup=$s.BasicAttackGroup
                TimingRole=$s.TimingRole
            })
            $slot++
        }

        # IMPORTANT FIX:
        # Windows PowerShell 5.1 can throw "Argument types do not match"
        # when @($genericList) is used. Convert explicitly to a real object array.
        $entryArray = $entries.ToArray()
        $issues = @(Test-ILPreset -Entries $entryArray -Level $Level)

        $lines.Add("============================================================")
        $lines.Add($scenario.ScenarioName)
        $lines.Add("============================================================")
        $lines.Add("Template: $($template.Label)")
        $lines.Add("Status: $($template.PresetStatus)")
        $lines.Add("Availability: $($scenario.AvailabilityType)")
        $lines.Add("Currently live: $($scenario.CurrentlyLive)")
        if (-not $scenario.CurrentlyLive) {
            $lines.Add("Note: inactive content remains available for preset preparation.")
        }
        if ($scenario.Notes) { $lines.Add("Scenario note: $($scenario.Notes)") }
        if ($template.Notes) { $lines.Add("Template note: $($template.Notes)") }
        $lines.Add("")

        foreach($e in $entryArray) {
            $lines.Add(("{0,2}. {1}" -f $e.Slot,$e.SkillName))
        }

        $lines.Add("")
        $lines.Add("Auto-use: UNKNOWN unless explicitly sourced.")
        if ($issues.Count -eq 0) {
            $lines.Add("Legality: PASS")
        } else {
            $lines.Add("Legality: FAIL")
            foreach($i in $issues) { $lines.Add(" - $i") }
        }

        if ($ValidationHistory.ContainsKey($scenario.ScenarioId)) {
            $lines.Add("")
            $lines.Add("USER VALIDATION - separate from community baseline")
            foreach($v in $ValidationHistory[$scenario.ScenarioId]) {
                $lines.Add(("- {0}: {1} ({2})" -f $v.Label,$v.Result,$v.Date))
            }
        }

        $lines.Add("")
    }

    return ($lines -join [Environment]::NewLine)
}

function Make-Report([string]$ClassName,[int]$Level) {
    if ($ClassName -eq "Arch Mage (Ice/Lightning)") {
        return Make-ILReport $Level
    }

    $lines = @(
        "MAPLESTORY IDLE RPG - MAPLESKILLS",
        "MapleSkills v$AppVersion",
        "Class: $ClassName",
        "Character level: $Level",
        "",
        "COMMUNITY DATA UPDATE REQUIRED",
        "",
        "This class remains selectable, but its new level-aware scenario-template data has not yet been rebuilt under the current KISS model.",
        "MapleSkills will not invent skill trees."
    )
    return ($lines -join [Environment]::NewLine)
}

function Get-OutputFolder {
    $p="C:\MapleProjects\Downloads"
    if (-not (Test-Path "C:\MapleProjects")) {
        $p=Join-Path $env:USERPROFILE "Downloads\MapleSkills"
    }
    New-Item -ItemType Directory -Force -Path $p | Out-Null
    return $p
}

# ============================================================
# SIMPLE UI
# ============================================================

$form=New-Object System.Windows.Forms.Form
$form.Text="$AppName v$AppVersion"
$form.Size=New-Object System.Drawing.Size(620,360)
$form.StartPosition="CenterScreen"
$form.MaximizeBox=$false
$form.FormBorderStyle="FixedDialog"

$title=New-Object System.Windows.Forms.Label
$title.Text="MapleSkills"
$title.Font=New-Object System.Drawing.Font("Segoe UI",20,[System.Drawing.FontStyle]::Bold)
$title.Location=New-Object System.Drawing.Point(25,20)
$title.AutoSize=$true
$form.Controls.Add($title)

$sub=New-Object System.Windows.Forms.Label
$sub.Text="Pick your character and level. Generate all available skill trees."
$sub.Location=New-Object System.Drawing.Point(29,65)
$sub.Size=New-Object System.Drawing.Size(540,30)
$form.Controls.Add($sub)

$classLabel=New-Object System.Windows.Forms.Label
$classLabel.Text="Character"
$classLabel.Location=New-Object System.Drawing.Point(30,115)
$classLabel.AutoSize=$true
$form.Controls.Add($classLabel)

$classBox=New-Object System.Windows.Forms.ComboBox
$classBox.DropDownStyle="DropDownList"
$classBox.Location=New-Object System.Drawing.Point(30,140)
$classBox.Size=New-Object System.Drawing.Size(340,30)
[void]$classBox.Items.AddRange([object[]]$Classes)
$classBox.SelectedItem="Arch Mage (Ice/Lightning)"
$form.Controls.Add($classBox)

$levelLabel=New-Object System.Windows.Forms.Label
$levelLabel.Text="Level"
$levelLabel.Location=New-Object System.Drawing.Point(410,115)
$levelLabel.AutoSize=$true
$form.Controls.Add($levelLabel)

$levelBox=New-Object System.Windows.Forms.NumericUpDown
$levelBox.Minimum=1
$levelBox.Maximum=125
$levelBox.Value=110
$levelBox.Location=New-Object System.Drawing.Point(410,140)
$levelBox.Size=New-Object System.Drawing.Size(120,30)
$form.Controls.Add($levelBox)

$gen=New-Object System.Windows.Forms.Button
$gen.Text="GENERATE ALL SKILL TREES"
$gen.Location=New-Object System.Drawing.Point(30,215)
$gen.Size=New-Object System.Drawing.Size(500,60)
$form.Controls.Add($gen)

$gen.Add_Click({
    try {
        $className=$classBox.SelectedItem.ToString()
        $level=[int]$levelBox.Value
        $txt=Make-Report -ClassName $className -Level $level
        $folder=Get-OutputFolder
        $safeClass=($className -replace '[^A-Za-z0-9]+','_').Trim('_')
        $path=Join-Path $folder ("MapleSkills_{0}_Lv{1}_v{2}.txt" -f $safeClass,$level,$AppVersion)
        Set-Content -Path $path -Value $txt -Encoding UTF8
        Start-Process explorer.exe -ArgumentList "/select,`"$path`""
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            "MapleSkills Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        ) | Out-Null
    }
})

[void]$form.ShowDialog()
