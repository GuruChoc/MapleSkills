Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$AppName = "MapleSkills"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VersionFile = Join-Path $ScriptDir "VERSION.txt"
$AppVersion = if (Test-Path $VersionFile) { (Get-Content $VersionFile -Raw).Trim() } else { "UNKNOWN" }
$Reviewed = "2026-08-25"

function S([string]$Name,[int]$Level,[bool]$Basic=$false) {
    [pscustomobject]@{ Name=$Name; Level=$Level; Basic=$Basic }
}

$Classes = [ordered]@{}

function Add-ProgressiveClass($Name,$Status,$Sources,$Skills,$Basic,$Base) {
    $Classes[$Name] = @{
        Status=$Status; Mode="Progressive"; LastReviewed=$Reviewed;
        Sources=$Sources; Skills=$Skills; Basic=$Basic; Base=$Base
    }
}
function Add-DraftClass($Name,$Sources,$Base) {
    $Classes[$Name] = @{
        Status="COMMUNITY DRAFT"; Mode="FourthJobDraft"; LastReviewed=$Reviewed;
        Sources=$Sources; Skills=@(); Basic=@(); Base=$Base
    }
}

Add-ProgressiveClass "Arch Mage (Ice/Lightning)" "COMMUNITY BASELINE" @(
"https://maplestoryidle.info/guides/ice-lightning-presets/",
"https://maplestoryidle.info/jobs.html",
"https://idle.maplestorywiki.net/w/Arch_Mage_%28Ice_Lightning%29/Skills"
) @(
(S "Nimble Feet" 1),(S "Energy Bolt" 1 $true),(S "Teleport" 10),(S "Magic Guard" 15),
(S "Cold Beam" 30 $true),(S "Thunder Bolt" 38),(S "Meditation" 40),(S "Ice Strike" 60 $true),
(S "Glacier Wall" 63),(S "Thunder Sphere" 69),(S "Chain Lightning" 100 $true),
(S "Freezing Breath" 103),(S "Blizzard" 105),(S "Frozen Orb" 107),(S "Infinity" 110),(S "Elquines" 115)
) @("Energy Bolt","Cold Beam","Ice Strike","Chain Lightning") @(
"Blizzard","Infinity","Meditation","Frozen Orb","Freezing Breath","Chain Lightning",
"Elquines","Nimble Feet","Teleport","Thunder Sphere","Glacier Wall","Magic Guard"
)

Add-ProgressiveClass "Arch Mage (Fire/Poison)" "COMMUNITY BASELINE" @(
"https://maplestoryidle.info/guides/fire-poison-presets/",
"https://maplestoryidle.info/jobs.html",
"https://idle.maplestorywiki.net/w/Arch_Mage_%28Fire_Poison%29/Skills"
) @(
(S "Nimble Feet" 1),(S "Energy Bolt" 1 $true),(S "Teleport" 10),(S "Magic Guard" 15),
(S "Flame Orb" 30 $true),(S "Poison Breath" 38),(S "Meditation" 40),(S "Explosion" 60 $true),
(S "Poison Mist" 63),(S "Creeping Toxin" 69),(S "Flame Sweep" 100 $true),
(S "Meteor Shower" 105),(S "Flame Haze" 107),(S "Infinity" 110),(S "Ifrit" 115)
) @("Energy Bolt","Flame Orb","Explosion","Flame Sweep") @(
"Meteor Shower","Infinity","Meditation","Poison Mist","Creeping Toxin","Flame Haze",
"Flame Sweep","Ifrit","Nimble Feet","Teleport","Magic Guard","Poison Breath"
)

Add-ProgressiveClass "Bishop" "COMMUNITY BASELINE" @(
"https://maplestoryidle.info/guides.html",
"https://maplestoryidle.info/jobs.html",
"https://idle.maplestorywiki.net/w/Bishop/Skills"
) @(
(S "Energy Bolt" 1 $true),(S "Nimble Feet" 1),(S "Teleport" 10),(S "Magic Guard" 15),
(S "Holy Arrow" 30 $true),(S "Heal" 38),(S "Bless" 40),(S "Shining Ray" 60 $true),
(S "Holy Fountain" 66),(S "Holy Magic Shell" 69),(S "Big Bang" 100 $true),
(S "Angel Ray" 103),(S "Genesis" 105),(S "Advanced Blessing" 107),(S "Infinity" 110),(S "Bahamut" 115)
) @("Energy Bolt","Holy Arrow","Shining Ray","Big Bang") @(
"Advanced Blessing","Infinity","Bless","Holy Magic Shell","Genesis","Angel Ray",
"Big Bang","Bahamut","Heal","Holy Fountain","Nimble Feet","Teleport"
)

Add-ProgressiveClass "Marksman" "COMMUNITY BASELINE" @(
"https://maplestoryidle.info/guides/marksman-presets/",
"https://maplestoryidle.info/jobs.html",
"https://idle.maplestorywiki.net/w/Marksman/Skills"
) @(
(S "Nimble Feet" 1),(S "Arrow Blow" 1 $true),(S "Piercing Arrow" 30 $true),(S "Covering Fire" 35),
(S "Piercing Arrow II" 60 $true),(S "Blink Bolt" 60),(S "Bolt Burst" 63),(S "Pain Killer" 66),
(S "Frostprey" 69),(S "Empowered Piercing Arrow" 100 $true),(S "Snipe" 103),
(S "Arrow Illusion" 110),(S "Sharp Eyes" 115)
) @("Arrow Blow","Piercing Arrow","Piercing Arrow II","Empowered Piercing Arrow") @(
"Blink Bolt","Nimble Feet","Pain Killer","Bolt Burst","Covering Fire","Frostprey",
"Empowered Piercing Arrow","Snipe","Arrow Illusion","Sharp Eyes"
)

Add-ProgressiveClass "Night Lord" "COMMUNITY BASELINE" @(
"https://maplestoryidle.info/guides/night-lord-presets/",
"https://maplestoryidle.info/jobs.html",
"https://idle.maplestorywiki.net/w/Night_Lord/Skills"
) @(
(S "Nimble Feet" 1),(S "Lucky Seven" 1 $true),(S "Dark Sight" 15),(S "Shuriken Burst" 30 $true),
(S "Gust Charm" 35),(S "Shadow Surge" 50),(S "Shuriken Challenge" 60 $true),(S "Triple Throw" 63),
(S "Dark Flare" 69),(S "Showdown" 100 $true),(S "Quad Star" 103),(S "Sudden Raid" 105),(S "Frailty Curse" 110)
) @("Lucky Seven","Shuriken Burst","Shuriken Challenge","Showdown") @(
"Frailty Curse","Quad Star","Sudden Raid","Showdown","Dark Flare","Triple Throw",
"Gust Charm","Shadow Surge","Dark Sight","Nimble Feet"
)

Add-ProgressiveClass "Shadower" "COMMUNITY BASELINE" @(
"https://maplestoryidle.info/guides/shadower-presets/",
"https://maplestoryidle.info/jobs.html",
"https://idle.maplestorywiki.net/w/Shadower/Skills"
) @(
(S "Nimble Feet" 1),(S "Double Stab" 1 $true),(S "Dark Sight" 15),(S "Savage Blow" 30 $true),
(S "Midnight Carnival" 60 $true),(S "Phase Dash" 63),(S "Meso Explosion" 66),(S "Dark Flare" 69),
(S "Into Darkness" 74),(S "Cruel Stab" 100 $true),(S "Assassinate" 103),(S "Sudden Raid" 105),(S "Smokescreen" 110)
) @("Double Stab","Savage Blow","Midnight Carnival","Cruel Stab") @(
"Into Darkness","Smokescreen","Assassinate","Sudden Raid","Cruel Stab","Meso Explosion",
"Dark Flare","Phase Dash","Dark Sight","Nimble Feet"
)

Add-DraftClass "Hero" @(
"https://maplestoryidle.info/guides/hero-presets/",
"https://maplestoryidle.info/jobs.html",
"https://idle.maplestorywiki.net/w/Hero/Skills"
) @("Nimble Feet","Spirit Blade","Flash Slash","Beam Blade","Rush","Scaring Sword","Raging Blow","Puncture","Enhanced Raging Blow")

Add-DraftClass "Paladin" @(
"https://maplestoryidle.info/guides.html",
"https://maplestoryidle.info/jobs.html",
"https://idle.maplestorywiki.net/w/Paladin/Skills"
) @("Nimble Feet","Noble Demand","Combat Orders","HP Recovery","Rush","Blast","Heaven's Hammer","Close Combat")

Add-DraftClass "Dark Knight" @(
"https://maplestoryidle.info/guides/dark-knight-presets/",
"https://maplestoryidle.info/jobs.html",
"https://idle.maplestorywiki.net/w/Dark_Knight/Skills"
) @("Nimble Feet","Magic Crash","Evil Eye Shock","Dark Impale","Gungnir's Descent","Rush")

Add-DraftClass "Bowmaster" @(
"https://maplestoryidle.info/guides/bowmaster-presets/",
"https://maplestoryidle.info/jobs.html",
"https://idle.maplestorywiki.net/w/Bowmaster/Skills"
) @("Arrow Platter","Sharp Eyes","Phoenix","Nimble Feet","Covering Fire","Hurricane","Arrow Stream")

Add-DraftClass "Buccaneer" @(
"https://maplestoryidle.info/guides.html",
"https://maplestoryidle.info/jobs.html",
"https://idle.maplestorywiki.net/w/Buccaneer/Skills"
) @("Time Leap","Speed Infusion","Crossbones","Nautilus Strike","Octopunch","Hook Bomber","Serpent Scale","Corkscrew Blow","Roll of the Dice")

Add-DraftClass "Corsair" @(
"https://maplestoryidle.info/guides.html",
"https://maplestoryidle.info/jobs.html",
"https://idle.maplestorywiki.net/w/Corsair/Skills"
) @("Community source review required - Corsair tree intentionally not guessed")

Add-DraftClass "Night Walker" @(
"https://maplestoryidle.info/jobs.html",
"https://forum.nexon.com/maplestoryidle/",
"https://maplestoryidle.info/guides.html"
) @("Elemental Harmony","Dark Elemental","Shadow Double","Darkness Ascending","Quintuple Star","Dark Omen","Shadow Stitch","Dark Evasion","Shadow Spark")

Add-DraftClass "Wind Archer" @(
"https://maplestoryidle.info/jobs.html",
"https://forum.nexon.com/maplestoryidle/",
"https://maplestoryidle.info/guides.html"
) @("Elemental Harmony","Storm Elemental","Wind Walk","Spiraling Vortex","Song of Heaven","Monsoon")

$Scenarios = @(
"HUNT / FARMING",
"CHAPTER BREAKTHROUGH / MIXED",
"DIRECT BOSS",
"ARENA / COLOSSEUM / WORLD ARENA",
"GUILD CONQUEST",
"GUILD WAR / GUILD RAID"
)

function Get-CurrentBasic($data,[int]$level) {
    $b = @($data.Skills | Where-Object { $_.Basic -and $_.Level -le $level } | Sort-Object Level)
    if ($b.Count -eq 0) { return $null }
    return $b[-1].Name
}
function Get-ProgressiveBuild($data,[int]$level) {
    $basic = Get-CurrentBasic $data $level
    $avail = @()
    foreach($s in $data.Skills) {
        if ($s.Level -le $level -and (-not $s.Basic -or $s.Name -eq $basic)) { $avail += $s.Name }
    }
    $ordered = New-Object System.Collections.Generic.List[string]
    foreach($name in $data.Base) {
        $candidate = $name
        if (($data.Basic -contains $name) -and $basic) { $candidate=$basic }
        if (($avail -contains $candidate) -and -not ($ordered -contains $candidate)) { $ordered.Add($candidate) }
    }
    foreach($name in $avail) {
        if ($ordered.Count -ge 12) { break }
        if (-not ($ordered -contains $name)) { $ordered.Add($name) }
    }
    return @($ordered | Select-Object -First 12)
}
function Get-ScenarioOrder([string[]]$base,[string]$scenario) {
    if ($scenario -eq "ARENA / COLOSSEUM / WORLD ARENA") {
        $p=@("Dark Sight","Into Darkness","Smokescreen","Pain Killer","Blink Bolt","Nimble Feet","Magic Guard","Heal","Holy Magic Shell","Dark Evasion","Wind Walk","Rush")
        return @($p+$base | Select-Object -Unique)
    }
    if ($scenario -eq "GUILD CONQUEST") {
        $p=@("Smokescreen","Noble Demand","Magic Crash","Frailty Curse","Scaring Sword","Crossbones")
        return @($p+$base | Select-Object -Unique)
    }
    return @($base)
}
function Get-OutputFolder {
    $p="C:\MapleProjects\Downloads"
    if (-not (Test-Path "C:\MapleProjects")) { $p=Join-Path $env:USERPROFILE "Downloads\MapleSkills" }
    New-Item -ItemType Directory -Force -Path $p | Out-Null
    return $p
}
function Make-Report([string]$className,[int]$level) {
    $d=$Classes[$className]
    $l=New-Object System.Collections.Generic.List[string]
    $l.Add("MAPLESTORY IDLE RPG - MAPLESKILLS COMMUNITY SKILL BUILDS")
    $l.Add("MapleSkills v$AppVersion")
    $l.Add("Class: $className")
    $l.Add("Level: $level")
    $l.Add("Last reviewed: $($d.LastReviewed)")
    $l.Add("Build status: $($d.Status)")
    $l.Add("")
    $l.Add("IMPORTANT COMMUNITY WARNING")
    $l.Add("These builds are community-sourced starting points, not official Nexon recommendations and not guaranteed optimal.")
    $l.Add("Balance patches, account stats, skill levels, timing, content mechanics and player testing can change the best order.")
    $l.Add("Corrections and better-performing community results are welcome.")
    $l.Add("")
    if ($d.Mode -eq "FourthJobDraft" -and $level -lt 100) {
        $l.Add("PROGRESSION WARNING")
        $l.Add("This class currently has a 4th-job COMMUNITY DRAFT only; a lower-level tree is intentionally not guessed.")
        $l.Add("")
    }
    $base = if ($d.Mode -eq "Progressive") { @(Get-ProgressiveBuild $d $level) } else { @($d.Base | Select-Object -First 12) }
    foreach($sc in $Scenarios) {
        $l.Add("============================================================")
        $l.Add($sc)
        $l.Add("============================================================")
        if ($d.Mode -eq "FourthJobDraft" -and $level -lt 100) {
            $l.Add("No lower-level community tree published yet for this class.")
            $l.Add("")
            continue
        }
        $build=@(Get-ScenarioOrder $base $sc | Select-Object -First 12)
        $i=1
        foreach($skill in $build) { $l.Add(("{0,2}. {1}" -f $i,$skill)); $i++ }
        $l.Add("")
    }
    $l.Add("SOURCES / REFERENCES")
    foreach($u in $d.Sources) { $l.Add($u) }
    $l.Add("")
    $l.Add("General references:")
    $l.Add("https://maplestoryidle.info/jobs.html")
    $l.Add("https://maplestoryidle.info/guides.html")
    $l.Add("https://idle.maplestorywiki.net/w/Skills")
    $l.Add("https://forum.nexon.com/maplestoryidle/")
    $l.Add("")
    $l.Add("Feedback: maple@arcadeheaven.com")
    $l.Add("Unofficial community tool. MapleStory and related names belong to their respective owners.")
    return ($l -join [Environment]::NewLine)
}

$form=New-Object System.Windows.Forms.Form
$form.Text="$AppName v$AppVersion - Community Skill Build Generator"
$form.Size=New-Object System.Drawing.Size(760,500)
$form.StartPosition="CenterScreen"

$title=New-Object System.Windows.Forms.Label
$title.Text="MapleSkills v$AppVersion"
$title.Font=New-Object System.Drawing.Font("Segoe UI",18,[System.Drawing.FontStyle]::Bold)
$title.Location=New-Object System.Drawing.Point(25,20); $title.AutoSize=$true; $form.Controls.Add($title)

$sub=New-Object System.Windows.Forms.Label
$sub.Text="Community-sourced skill builds - feedback and corrections are always welcome."
$sub.Location=New-Object System.Drawing.Point(29,60); $sub.Size=New-Object System.Drawing.Size(680,25); $form.Controls.Add($sub)

$cl=New-Object System.Windows.Forms.Label
$cl.Text="Character / Class"; $cl.Location=New-Object System.Drawing.Point(30,105); $cl.AutoSize=$true; $form.Controls.Add($cl)

$classBox=New-Object System.Windows.Forms.ComboBox
$classBox.DropDownStyle="DropDownList"; $classBox.Location=New-Object System.Drawing.Point(30,130); $classBox.Size=New-Object System.Drawing.Size(340,30)
[void]$classBox.Items.AddRange([object[]]@($Classes.Keys)); $classBox.SelectedIndex=0; $form.Controls.Add($classBox)

$ll=New-Object System.Windows.Forms.Label
$ll.Text="Level"; $ll.Location=New-Object System.Drawing.Point(410,105); $ll.AutoSize=$true; $form.Controls.Add($ll)
$levelBox=New-Object System.Windows.Forms.NumericUpDown
$levelBox.Minimum=1; $levelBox.Maximum=125; $levelBox.Value=107; $levelBox.Location=New-Object System.Drawing.Point(410,130); $form.Controls.Add($levelBox)

$status=New-Object System.Windows.Forms.Label
$status.Location=New-Object System.Drawing.Point(30,180); $status.Size=New-Object System.Drawing.Size(680,70); $status.BorderStyle="FixedSingle"; $form.Controls.Add($status)

$warning=New-Object System.Windows.Forms.Label
$warning.Text="COMMUNITY WARNING: Starting points only. Not official, not set in stone. Patches, account strength and timing can change the best build."
$warning.Location=New-Object System.Drawing.Point(30,265); $warning.Size=New-Object System.Drawing.Size(680,50); $warning.ForeColor=[System.Drawing.Color]::DarkRed; $form.Controls.Add($warning)

$gen=New-Object System.Windows.Forms.Button
$gen.Text="GENERATE COMMUNITY SKILL BUILDS"; $gen.Location=New-Object System.Drawing.Point(30,335); $gen.Size=New-Object System.Drawing.Size(330,55); $form.Controls.Add($gen)
$src=New-Object System.Windows.Forms.Button
$src.Text="OPEN SOURCES"; $src.Location=New-Object System.Drawing.Point(380,335); $src.Size=New-Object System.Drawing.Size(150,55); $form.Controls.Add($src)
$fb=New-Object System.Windows.Forms.Button
$fb.Text="EMAIL FEEDBACK"; $fb.Location=New-Object System.Drawing.Point(550,335); $fb.Size=New-Object System.Drawing.Size(160,55); $form.Controls.Add($fb)

function Refresh-Status {
    $d=$Classes[$classBox.SelectedItem.ToString()]
    $status.Text="Status: $($d.Status)`r`nLast reviewed: $($d.LastReviewed)`r`nMode: $($d.Mode)"
}
$classBox.Add_SelectedIndexChanged({Refresh-Status}); Refresh-Status

$gen.Add_Click({
    $c=$classBox.SelectedItem.ToString(); $lv=[int]$levelBox.Value
    $txt=Make-Report $c $lv; $folder=Get-OutputFolder
    $safe=($c -replace '[^A-Za-z0-9]+','_').Trim('_')
    $path=Join-Path $folder ("MapleSkills_{0}_Lv{1}_v{2}.txt" -f $safe,$lv,$AppVersion)
    Set-Content $path $txt -Encoding UTF8
    Start-Process explorer.exe -ArgumentList "/select,`"$path`""
})
$src.Add_Click({ Start-Process (Join-Path $ScriptDir "SOURCES.md") })
$fb.Add_Click({
    $c=$classBox.SelectedItem.ToString(); $lv=[int]$levelBox.Value
    $subject=[uri]::EscapeDataString("MapleSkills feedback - $c Lv$lv - v$AppVersion")
    $body=[uri]::EscapeDataString("Please add your feedback here.`r`n`r`nClass: $c`r`nLevel: $lv`r`nMapleSkills: v$AppVersion`r`n`r`nWhat worked?`r`n`r`nWhat should change?`r`n`r`nWhat performed better?")
    Start-Process ("mailto:maple@arcadeheaven.com?subject=$subject&body=$body")
})
[void]$form.ShowDialog()
