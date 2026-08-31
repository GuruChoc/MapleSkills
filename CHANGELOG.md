# Changelog

## v0.8.0 - 2026-09-01

Level-aware scenario preset architecture and KISS interface.

- Simplified the UI to Character + Level + Generate All Skill Trees.
- Generates all mapped skill trees in one report instead of requiring scenario-by-scenario generation.
- Added sourced, level-aware, ordered scenario presets.
- Added reusable scenario-to-template mapping.
- Added rotating/inactive scenario support without removing presets.
- Added Auto-use as a first-class preset field.
- Added Basic Attack conflict enforcement.
- Updated I/L Mage Lv110 to use the exact current 12-skill usable pool.
- Standardized the current I/L player-facing name Frost Ward.
- Kept community baseline and user validation data separate.
- Added user-validation history without allowing test results to silently redefine community presets.
- Fixed the Windows PowerShell 5.1 generic-list conversion failure discovered during live testing.
- No future/locked I/L skills are used as placeholders in current Lv110 builds.

## v0.7.1 - 2026-08-26

Release-integrity maintenance release.

- Added CHANGELOG.md.
- Added UTF-8/mojibake release gating.
- Added exact live-code versus GitHub verification.
- Added exact Git diff capture.
- Added SHA-256 release ZIP manifesting.
- Added fresh-tag/fresh-release protection; existing tags/releases are never overwritten.
- Added independent public ZIP re-download and verification.
- No intentional skill-tree behaviour change from v0.7.

## v0.7 - 2026-08-25

Community class expansion.

- MapleSkills-only public naming.
- VERSION.txt became the authoritative version source.
- Added all 14 current classes.
- Added COMMUNITY BASELINE / COMMUNITY DRAFT labels.
- Removed personal I/L testing language.
- Added community warnings, feedback policy and SOURCES.md.
