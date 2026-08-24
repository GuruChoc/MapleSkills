Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$AppVersion = "0.6"
$ClassName = "Arch Mage (Ice/Lightning)"

# Current MapleStory Idle RPG I/L active skill unlocks.
# Sources checked 2026-08-24:
# - maplestoryidle.info current class guide / August 13 refresh
# - MapleStory Idle RPG Wiki skill reference
$Skills = @(
    [pscustomobject]@{ Name="Nimble Feet";      Level=1;   Basic=$false }
    [pscustomobject]@{ Name="Energy Bolt";      Level=1;   Basic=$true  }
    [pscustomobject]@{ Name="Teleport";         Level=10;  Basic=$false }
    [pscustomobject]@{ Name="Magic Guard";      Level=15;  Basic=$false }
    [pscustomobject]@{ Name="Cold Beam";        Level=30;  Basic=$true  }
    [pscustomobject]@{ Name="Thunder Bolt";     Level=38;  Basic=$false }
    [pscustomobject]@{ Name="Meditation";       Level=40;  Basic=$false }
    [pscustomobject]@{ Name="Ice Strike";       Level=60;  Basic=$true  }
    [pscustomobject]@{ Name="Glacier Wall";     Level=63;  Basic=$false }
    [pscustomobject]@{ Name="Thunder Sphere";   Level=69;  Basic=$false }
    [pscustomobject]@{ Name="Chain Lightning";  Level=100; Basic=$true  }
    [pscustomobject]@{ Name="Freezing Breath";  Level=103; Basic=$false }
    [pscustomobject]@{ Name="Blizzard";         Level=105; Basic=$false }
    [pscustomobject]@{ Name="Frozen Orb";       Level=107; Basic=$false }
    [pscustomobject]@{ Name="Infinity";          Level=110; Basic=$false }
    [pscustomobject]@{ Name="Elquines";          Level=115; Basic=$false }
)

$PassiveBreakpoints = @(
    [pscustomobject]@{ Level=35;  Name="Freezing Effect / Frost engine starts" }
    [pscustomobject]@{ Level=66;  Name="Frozen Break" }
    [pscustomobject]@{ Level=72;  Name="Elemental Reset" }
    [pscustomobject]@{ Level=74;  Name="Magic Critical" }
    [pscustomobject]@{ Level=75;  Name="Element Amplification" }
    [pscustomobject]@{ Level=100; Name="Maple Hero" }
    [pscustomobject]@{ Level=117; Name="Buff Mastery" }
    [pscustomobject]@{ Level=120; Name="Arcane Aim" }
    [pscustomobject]@{ Level=125; Name="Frost Clutch" }
)

# Current community 4th-job ordering is used as the target shape.
# For earlier levels the engine filters unavailable skills and substitutes
# the strongest unlocked Basic Attack Effect.
$Templates = [ordered]@{
    "1. HUNT / FARMING" = @{
        Order = @("Teleport","Infinity","Meditation","Nimble Feet","Blizzard","Chain Lightning",
                  "Frozen Orb","Elquines","Freezing Breath","Thunder Sphere","Glacier Wall","Magic Guard")
        UseFor = @("Chapter Hunt","Equipment Growth Dungeon","Experience Growth Dungeon",
                   "Hero Growth Dungeon","Star Force Hunting Zone")
        Note = "Teleport and buffs are kept early. Judge farming by KPM / EXP per minute."
    }
    "2. CHAPTER BREAKTHROUGH / MIXED" = @{
        Order = @("Blizzard","Infinity","Meditation","Frozen Orb","Freezing Breath","Chain Lightning",
                  "Elquines","Nimble Feet","Teleport","Thunder Sphere","Glacier Wall","Magic Guard")
        UseFor = @("Chapter Breakthrough","Hero Training Ground")
        Note = "Current guidance starts from the boss-style page, then moves Freezing Breath if boss timing misses."
    }
    "3. DIRECT BOSS" = @{
        Order = @("Blizzard","Infinity","Meditation","Frozen Orb","Freezing Breath","Chain Lightning",
                  "Elquines","Nimble Feet","Glacier Wall","Thunder Sphere","Magic Guard","Thunder Bolt")
        UseFor = @("Chapter Boss","Weapon Growth Dungeon","World Boss","Boss Raid: Zakum","Boss Raid: Horntail")
        Note = "Ice setup comes before the lightning payoff. Freezing Breath is timing-sensitive."
    }
    "4. ENHANCEMENT – MOVEMENT BOSS" = @{
        Order = @("Blizzard","Infinity","Meditation","Frozen Orb","Freezing Breath","Chain Lightning",
                  "Elquines","Nimble Feet","Glacier Wall","Thunder Sphere","Magic Guard","Thunder Bolt")
        UseFor = @("Enhancement Growth Dungeon")
        Note = "Boss-style baseline. Move Freezing Breath only when target timing proves it is needed."
    }
    "5. PARTY QUEST – MIXED" = @{
        Order = @("Blizzard","Infinity","Meditation","Frozen Orb","Freezing Breath","Chain Lightning",
                  "Elquines","Nimble Feet","Teleport","Thunder Sphere","Glacier Wall","Magic Guard")
        UseFor = @("First Time Together","Dimensional Crack","Remnant of the Goddess","Romeo and Juliet")
        Note = "Mixed-content baseline. First Time Together can favour the farming order; durable final targets favour boss order."
    }
    "6. ARENA / COLOSSEUM / WORLD ARENA" = @{
        Order = @("Meditation","Magic Guard","Nimble Feet","Freezing Breath","Glacier Wall","Frozen Orb",
                  "Chain Lightning","Elquines","Infinity","Teleport","Thunder Sphere","Blizzard")
        UseFor = @("Arena","Colosseum","World Arena")
        Note = "PvP order protects the stronger attack buff from early buff removal where possible."
    }
    "7. GUILD CONQUEST" = @{
        Order = @("Blizzard","Infinity","Meditation","Frozen Orb","Freezing Breath","Chain Lightning",
                  "Elquines","Nimble Feet","Glacier Wall","Thunder Sphere","Magic Guard","Thunder Bolt")
        UseFor = @("Guild Conquest")
        Note = "Boss-pressure baseline with Frost setup before lightning payoff."
    }
    "8. GUILD WAR" = @{
        Order = @("Meditation","Magic Guard","Nimble Feet","Freezing Breath","Glacier Wall","Frozen Orb",
                  "Chain Lightning","Elquines","Infinity","Teleport","Thunder Sphere","Blizzard")
        UseFor = @("Guild War")
        Note = "Survival, hit rate and buff order can matter more than pure damage."
    }
    "9. GUILD RAID – ZAKUM / SURVIVAL BOSS" = @{
        Order = @("Blizzard","Infinity","Meditation","Frozen Orb","Freezing Breath","Chain Lightning",
                  "Elquines","Nimble Feet","Glacier Wall","Thunder Sphere","Magic Guard","Thunder Bolt")
        UseFor = @("Guild Raid: Zakum")
        Note = "Boss-style baseline. Survival can override damage ordering if deaths are the wall."
    }
}

function Get-BasicAttack([int]$Level) {
    if ($Level -ge 100) { return "Chain Lightning" }
    if ($Level -ge 60)  { return "Ice Strike" }
    if ($Level -ge 30)  { return "Cold Beam" }
    return "Energy Bolt"
}

function Get-UnlockedCompatible([int]$Level) {
    $basic = Get-BasicAttack $Level
    $result = @()
    foreach ($s in $Skills) {
        if ($s.Level -le $Level) {
            if (-not $s.Basic -or $s.Name -eq $basic) {
                $result += $s.Name
            }
        }
    }
    return $result
}

function Get-Build([int]$Level, $TemplateOrder) {
    $basic = Get-BasicAttack $Level
    $unlocked = @(Get-UnlockedCompatible $Level)
    $ordered = New-Object System.Collections.Generic.List[string]

    foreach ($name in $TemplateOrder) {
        $candidate = $name
        if ($name -eq "Chain Lightning") {
            $candidate = $basic
        }
        if (($unlocked -contains $candidate) -and -not ($ordered -contains $candidate)) {
            $ordered.Add($candidate)
        }
    }

    # Fill every available compatible slot up to 12.
    # This is important at lower levels where the 4th-job template may omit
    # an older skill that is still useful because there is spare room.
    foreach ($name in $unlocked) {
        if ($ordered.Count -ge 12) { break }
        if (-not ($ordered -contains $name)) {
            $ordered.Add($name)
        }
    }

    # Never allow more than 12 equipped skills.
    if ($ordered.Count -gt 12) {
        return @($ordered | Select-Object -First 12)
    }
    return @($ordered)
}

function Get-Confidence([int]$Level) {
    if ($Level -lt 100) {
        return "THEORYCRAFT – exact unlocks are sourced; scenario order is inferred from current I/L mechanics and later community presets."
    }
    elseif ($Level -lt 115) {
        return "HYBRID – current community 4th-job structure filtered to the skills unlocked at this level."
    }
    else {
        return "COMMUNITY BASELINE – current August 2026 content presets, with timing/account adjustments still expected."
    }
}

function Get-OutputFolder {
    $maple = "C:\MapleProjects\Downloads"
    if (Test-Path "C:\MapleProjects") {
        New-Item -ItemType Directory -Force -Path $maple | Out-Null
        return $maple
    }

    $downloads = Join-Path $env:USERPROFILE "Downloads\MapleSkills"
    New-Item -ItemType Directory -Force -Path $downloads | Out-Null
    return $downloads
}

function Make-Report([int]$Level) {
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("MAPLESTORY IDLE RPG – ARCH MAGE (ICE/LIGHTNING) SKILL BUILDS – LEVEL $Level")
    $lines.Add("MapleSkills test build v$AppVersion")
    $lines.Add("")
    $lines.Add("CONFIDENCE")
    $lines.Add((Get-Confidence $Level))
    $lines.Add("")

    $unlocked = @(Get-UnlockedCompatible $Level)
    $basic = Get-BasicAttack $Level

    $lines.Add("UNLOCKED ACTIVE SKILLS USED BY THIS ENGINE")
    foreach ($s in $Skills | Where-Object { $_.Level -le $Level }) {
        $tag = ""
        if ($s.Basic) {
            if ($s.Name -eq $basic) { $tag = "  [CURRENT BASIC]" }
            else { $tag = "  [REPLACED BASIC – NOT EQUIPPED]" }
        }
        $lines.Add(("Lv.{0,-3} {1}{2}" -f $s.Level,$s.Name,$tag))
    }
    $lines.Add("")

    foreach ($key in $Templates.Keys) {
        $t = $Templates[$key]
        $build = @(Get-Build $Level $t.Order)

        $lines.Add($key)
        $lines.Add("")
        $slot = 1
        foreach ($skill in $build) {
            $lines.Add(("{0,2}. {1}" -f $slot,$skill))
            $slot++
        }
        if ($build.Count -lt 12) {
            $lines.Add("")
            $lines.Add("Open slots: " + (12 - $build.Count) + " – no additional compatible unlocked active skill is available.")
        }

        $lines.Add("")
        $lines.Add("USE FOR:")
        foreach ($u in $t.UseFor) { $lines.Add($u) }
        $lines.Add("")
        $lines.Add("NOTE:")
        $lines.Add($t.Note)
        $lines.Add("")
        $lines.Add("------------------------------------------------------------")
        $lines.Add("")
    }

    $lines.Add("BASIC ATTACK RULE")
    $lines.Add("$basic is the ONLY Basic Attack Effect equipped at Level $Level.")
    $olderBasics = @("Energy Bolt","Cold Beam","Ice Strike","Chain Lightning") | Where-Object { $_ -ne $basic -and (($Skills | Where-Object Name -eq $_).Level -le $Level) }
    if ($olderBasics.Count -gt 0) {
        $lines.Add("Do NOT equip replaced basics: " + ($olderBasics -join ", "))
    }
    $lines.Add("")

    $lines.Add("NEXT ACTIVE SKILL BREAKPOINTS")
    $future = @($Skills | Where-Object { $_.Level -gt $Level } | Sort-Object Level)
    if ($future.Count -eq 0) {
        $lines.Add("No later active-skill unlock is loaded.")
    } else {
        foreach ($s in $future | Select-Object -First 6) {
            $lines.Add("Lv.$($s.Level) – $($s.Name)")
        }
    }
    $lines.Add("")

    $lines.Add("NEXT PASSIVE / MECHANIC BREAKPOINTS")
    $pfuture = @($PassiveBreakpoints | Where-Object { $_.Level -gt $Level } | Sort-Object Level)
    if ($pfuture.Count -eq 0) {
        $lines.Add("No later passive breakpoint is loaded through Level 125.")
    } else {
        foreach ($p in $pfuture | Select-Object -First 6) {
            $lines.Add("Lv.$($p.Level) – $($p.Name)")
        }
    }
    $lines.Add("")

    $lines.Add("TEST NOTES")
    $lines.Add("- Levels below 100 are progressive theorycraft, not claimed as community-proven optimal.")
    $lines.Add("- Level 100+ uses the current I/L community content structure and filters it by unlock level.")
    $lines.Add("- Freezing Breath is timing-sensitive in boss content; move it if it fires before/after the real target.")
    $lines.Add("- At Level 115+, one compatible active must be omitted because more than 12 useful actives are available.")
    $lines.Add("- Current August 2026 baseline uses Glacier Wall. An older GMoney-tested Level 107 file used Frost Ward; this test build follows current Idle references.")
    $lines.Add("")

    $lines.Add("SOURCES CHECKED 2026-08-24")
    $lines.Add("https://maplestoryidle.info/guides/ice-lightning-presets/")
    $lines.Add("https://maplestoryidle.info/jobs.html")
    $lines.Add("https://idle.maplestorywiki.net/w/Arch_Mage_%28Ice_Lightning%29/Skills")
    $lines.Add("")
    $lines.Add("Unofficial community test tool. MapleStory and related names belong to their respective owners.")

    return ($lines -join [Environment]::NewLine)
}


$script:LastGeneratedFile = $null

function Get-ThunderbirdPath {
    $candidates = @(
        "$env:ProgramFiles\Mozilla Thunderbird\thunderbird.exe",
        "${env:ProgramFiles(x86)}\Mozilla Thunderbird\thunderbird.exe",
        "$env:LOCALAPPDATA\Mozilla Thunderbird\thunderbird.exe"
    )

    foreach ($p in $candidates) {
        if ($p -and (Test-Path $p)) { return $p }
    }

    try {
        $cmd = Get-Command thunderbird.exe -ErrorAction Stop
        if ($cmd.Source) { return $cmd.Source }
    } catch {}

    return $null
}

function Escape-ThunderbirdComposeValue {
    param([string]$Text)
    if ($null -eq $Text) { return "" }

    # Thunderbird -compose values are comma-delimited and single-quoted.
    # Remove CR, keep LF as escaped \n, and escape apostrophes conservatively.
    $v = $Text -replace "`r",""
    $v = $v -replace "`n","\n"
    $v = $v -replace "'","''"
    return $v
}

function New-FeedbackEmail {
    param(
        [string]$Recipient,
        [int]$Level,
        [string]$GoodText,
        [string]$BadText
    )

    if ([string]::IsNullOrWhiteSpace($Recipient) -or $Recipient -notmatch '^[^@\s]+@[^@\s]+\.[^@\s]+$') {
        [System.Windows.Forms.MessageBox]::Show(
            "Enter a valid feedback email address first.",
            "MapleSkills"
        ) | Out-Null
        return
    }

    if (-not $script:LastGeneratedFile -or -not (Test-Path $script:LastGeneratedFile)) {
        [System.Windows.Forms.MessageBox]::Show(
            "Generate a skill build first.",
            "MapleSkills"
        ) | Out-Null
        return
    }

    try {
        $buildText = Get-Content -LiteralPath $script:LastGeneratedFile -Raw -Encoding UTF8
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Could not read the generated build file.",
            "MapleSkills"
        ) | Out-Null
        return
    }

    $subject = "MapleSkills I/L feedback – Level $Level"

    # Leave a generous writing area at the very top so testers can type
    # immediately without hunting through the generated build.
    $body = @"





PLEASE TYPE ANY EXTRA FEEDBACK ABOVE THIS LINE
============================================================

MAPLESKILLS – GUILD TEST FEEDBACK

Character: Arch Mage (Ice/Lightning)
Level tested: $Level
Tool version: v$AppVersion

GOOD / WORKED WELL
$GoodText

BAD / NEEDS FIXING
$BadText

============================================================
GENERATED BUILD
============================================================

$buildText
"@

    # Use the default mail client. No attachment is required anymore because
    # the full generated build is pasted into the email body.
    try {
        $encodedSubject = [uri]::EscapeDataString($subject)
        $encodedBody = [uri]::EscapeDataString($body)

        # mailto length is usually sufficient for these generated text builds,
        # but Outlook COM is preferred when available because it handles long bodies better.
        try {
            $outlook = New-Object -ComObject Outlook.Application
            $mail = $outlook.CreateItem(0)
            $mail.To = $Recipient
            $mail.Subject = $subject
            $mail.Body = $body
            $mail.Display()
            return
        }
        catch {
            Start-Process ("mailto:{0}?subject={1}&body={2}" -f $Recipient,$encodedSubject,$encodedBody)
            return
        }
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Could not open your email program.`r`n`r`nThe generated build is still saved here:`r`n$script:LastGeneratedFile",
            "MapleSkills"
        ) | Out-Null
    }
}

# ---------------- GUI ----------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "MapleSkills – I/L Mage Guild Tester v$AppVersion"
$form.Size = New-Object System.Drawing.Size(760,720)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font("Segoe UI",10)

$title = New-Object System.Windows.Forms.Label
$title.Text = "MAPLESKILLS"
$title.Font = New-Object System.Drawing.Font("Segoe UI",20,[System.Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(24,20)
$form.Controls.Add($title)

$sub = New-Object System.Windows.Forms.Label
$sub.Text = "Arch Mage (Ice/Lightning) – progressive Level 1–125 build + guild feedback"
$sub.AutoSize = $true
$sub.Location = New-Object System.Drawing.Point(28,62)
$form.Controls.Add($sub)

$classLabel = New-Object System.Windows.Forms.Label
$classLabel.Text = "Character"
$classLabel.AutoSize = $true
$classLabel.Location = New-Object System.Drawing.Point(30,112)
$form.Controls.Add($classLabel)

$classBox = New-Object System.Windows.Forms.ComboBox
$classBox.Location = New-Object System.Drawing.Point(145,108)
$classBox.Size = New-Object System.Drawing.Size(300,28)
$classBox.DropDownStyle = "DropDownList"
[void]$classBox.Items.Add($ClassName)
$classBox.SelectedIndex = 0
$form.Controls.Add($classBox)

$levelLabel = New-Object System.Windows.Forms.Label
$levelLabel.Text = "Current Level"
$levelLabel.AutoSize = $true
$levelLabel.Location = New-Object System.Drawing.Point(30,157)
$form.Controls.Add($levelLabel)

$levelBox = New-Object System.Windows.Forms.NumericUpDown
$levelBox.Location = New-Object System.Drawing.Point(145,153)
$levelBox.Size = New-Object System.Drawing.Size(100,28)
$levelBox.Minimum = 1
$levelBox.Maximum = 125
$levelBox.Value = 1
$form.Controls.Add($levelBox)

$generate = New-Object System.Windows.Forms.Button
$generate.Text = "GENERATE SKILL BUILDS"
$generate.Size = New-Object System.Drawing.Size(230,42)
$generate.Location = New-Object System.Drawing.Point(30,210)
$form.Controls.Add($generate)

$preview = New-Object System.Windows.Forms.Button
$preview.Text = "SHOW BREAKPOINTS"
$preview.Size = New-Object System.Drawing.Size(190,42)
$preview.Location = New-Object System.Drawing.Point(275,210)
$form.Controls.Add($preview)

$status = New-Object System.Windows.Forms.Label
$status.Location = New-Object System.Drawing.Point(30,275)
$status.Size = New-Object System.Drawing.Size(680,90)
$status.Text = "Pick any level from 1 to 125.`r`n`r`nLevels 1–99 = THEORYCRAFT`r`nLevels 100–114 = HYBRID`r`nLevels 115+ = CURRENT COMMUNITY BASELINE"
$form.Controls.Add($status)


$feedbackGroup = New-Object System.Windows.Forms.GroupBox
$feedbackGroup.Text = "GUILD FEEDBACK"
$feedbackGroup.Location = New-Object System.Drawing.Point(30,375)
$feedbackGroup.Size = New-Object System.Drawing.Size(680,260)
$form.Controls.Add($feedbackGroup)

$emailLabel = New-Object System.Windows.Forms.Label
$emailLabel.Text = "Send feedback to"
$emailLabel.AutoSize = $true
$emailLabel.Location = New-Object System.Drawing.Point(18,30)
$feedbackGroup.Controls.Add($emailLabel)

$emailBox = New-Object System.Windows.Forms.TextBox
$emailBox.Location = New-Object System.Drawing.Point(145,26)
$emailBox.Size = New-Object System.Drawing.Size(350,28)
$emailBox.Text = "maple@arcadeheaven.com"
$feedbackGroup.Controls.Add($emailBox)

$goodLabel = New-Object System.Windows.Forms.Label
$goodLabel.Text = "GOOD / WORKED WELL"
$goodLabel.AutoSize = $true
$goodLabel.Location = New-Object System.Drawing.Point(18,70)
$feedbackGroup.Controls.Add($goodLabel)

$goodBox = New-Object System.Windows.Forms.TextBox
$goodBox.Location = New-Object System.Drawing.Point(180,66)
$goodBox.Size = New-Object System.Drawing.Size(470,60)
$goodBox.Multiline = $true
$goodBox.ScrollBars = "Vertical"
$feedbackGroup.Controls.Add($goodBox)

$badLabel = New-Object System.Windows.Forms.Label
$badLabel.Text = "BAD / NEEDS FIXING"
$badLabel.AutoSize = $true
$badLabel.Location = New-Object System.Drawing.Point(18,140)
$feedbackGroup.Controls.Add($badLabel)

$badBox = New-Object System.Windows.Forms.TextBox
$badBox.Location = New-Object System.Drawing.Point(180,136)
$badBox.Size = New-Object System.Drawing.Size(470,60)
$badBox.Multiline = $true
$badBox.ScrollBars = "Vertical"
$feedbackGroup.Controls.Add($badBox)

$emailButton = New-Object System.Windows.Forms.Button
$emailButton.Text = "EMAIL FEEDBACK + INCLUDE BUILD"
$emailButton.Location = New-Object System.Drawing.Point(180,207)
$emailButton.Size = New-Object System.Drawing.Size(300,38)
$feedbackGroup.Controls.Add($emailButton)

$emailButton.Add_Click({
    New-FeedbackEmail `
        -Recipient $emailBox.Text.Trim() `
        -Level ([int]$levelBox.Value) `
        -GoodText $goodBox.Text.Trim() `
        -BadText $badBox.Text.Trim()
})

$foot = New-Object System.Windows.Forms.Label
$foot.Location = New-Object System.Drawing.Point(30,650)
$foot.Size = New-Object System.Drawing.Size(680,35)
$foot.Text = "Unsupported claims are labelled; the app does not pretend early-level ordering is proven."
$form.Controls.Add($foot)

$generate.Add_Click({
    $level = [int]$levelBox.Value
    $folder = Get-OutputFolder
    $file = Join-Path $folder ("MapleSkills_ILM_Lv{0}.txt" -f $level)
    $report = Make-Report $level
    [System.IO.File]::WriteAllText($file,$report,[System.Text.UTF8Encoding]::new($true))
    $script:LastGeneratedFile = $file
    $status.Text = "DONE – Level $level generated.`r`n`r`n$file"
    Start-Process explorer.exe -ArgumentList "/select,`"$file`""
    [System.Windows.Forms.MessageBox]::Show("Skill build generated.`r`n`r`n$file","MapleSkills") | Out-Null
})

$preview.Add_Click({
    $msg = @"
ACTIVE BREAKPOINTS

Lv.1   Nimble Feet + Energy Bolt
Lv.10  Teleport
Lv.15  Magic Guard
Lv.30  Cold Beam replaces Energy Bolt
Lv.38  Thunder Bolt
Lv.40  Meditation
Lv.60  Ice Strike replaces Cold Beam
Lv.63  Glacier Wall
Lv.69  Thunder Sphere
Lv.100 Chain Lightning replaces Ice Strike
Lv.103 Freezing Breath
Lv.105 Blizzard
Lv.107 Frozen Orb
Lv.110 Infinity
Lv.115 Elquines

PASSIVE / MECHANIC CHECKS
Lv.35, 66, 72, 74, 75, 100, 117, 120, 125
"@
    [System.Windows.Forms.MessageBox]::Show($msg,"MapleSkills – Breakpoints") | Out-Null
})

[void]$form.ShowDialog()
