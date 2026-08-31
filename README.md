# MapleSkills

**MapleStory Idle RPG – Community Skill Build Generator**

Current public release: **v0.8.0**

MapleSkills is an unofficial, community-sourced skill-build tool for MapleStory Idle RPG.

## Important community warning

The builds in MapleSkills are **community-derived starting points**. They are not official Nexon recommendations and they are not guaranteed to be optimal.

Balance patches, account strength, skill levels, equipment, timing, content mechanics and new player testing can all change the best order.

Corrections and better-performing community results are always welcome.

## v0.8.0 highlights

- Simplified KISS interface: choose **Character**, choose **Level**, then generate all available skill trees in one report.
- Added the new sourced, level-aware, scenario-specific preset architecture.
- I/L Mage Lv110 uses the actual unlocked 12-skill pool only.
- Enforces Chain Lightning as the only active I/L Basic Attack at 4th Job.
- Uses the current player-facing skill name **Frost Ward**.
- Preserves exact skill order and Auto-use state in the preset model.
- Separates community baseline data from user validation results.
- Internally maps scenarios to reusable build templates instead of duplicating identical skill arrays.
- Keeps rotating/inactive scenarios available for advance preset preparation.
- Fixes the Windows PowerShell 5.1 generic-list conversion failure found during testing.

## Current class coverage

All 14 current classes remain exposed in the selector:

Hero, Paladin, Dark Knight, Arch Mage (Ice/Lightning), Arch Mage (Fire/Poison), Bishop, Bowmaster, Marksman, Night Lord, Shadower, Buccaneer, Corsair, Night Walker and Wind Archer.

The new level-aware scenario-template system is currently populated for Arch Mage (Ice/Lightning). Other classes remain selectable but MapleSkills will not invent replacement trees where the new community data has not yet been rebuilt.

## Versioning

`VERSION.txt` is the **authoritative version source**.

The application reads it at runtime. Git tags, GitHub Releases, release ZIP names and README version information must agree with it.

Current version: **v0.8.0**

## Download

https://github.com/GuruChoc/MapleSkills/releases

Download the latest `MapleSkills_vX.Y.Z.zip`.

## Run

1. Extract the release ZIP.
2. Double-click `Run_MapleSkills.bat`.
3. Choose your character.
4. Choose your level.
5. Click **GENERATE ALL SKILL TREES**.

## Feedback

**maple@arcadeheaven.com**

Useful feedback includes class, level, scenario, skill order, Auto-use state where known, and whether a tested preset performed better or worse.

## Sources / references

See [`SOURCES.md`](SOURCES.md).

Core references:

- https://maplestoryidle.info/jobs.html
- https://maplestoryidle.info/guides.html
- https://idle.maplestorywiki.net/w/Skills
- https://forum.nexon.com/maplestoryidle/

Unofficial community tool. MapleStory and related names belong to their respective owners.
