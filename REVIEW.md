# Code Review: ChartKit

Review date: 2026-06-16
Tracker: https://github.com/advatar/DevAdvatar/issues/9
Scope: `ChartKit` package root and owned source/test files; generated build, dependency, and git metadata directories were excluded.

## Summary

- Overall risk from this static sweep: **Medium**
- Manifest check: pass (`swift package dump-package --package-path ChartKit`)
- Products: ChartKit
- Targets: ChartKit, ChartKitTests
- Dependencies: none detected
- Source files: 47 code files (47 Swift, 0 other)
- Test files: 1 code files

## Findings

### 1. [Medium] Runtime failure shortcuts are present in source paths

Force throws/casts and fatal errors should be restricted to impossible states. User-driven, file-driven, network-driven, and model-driven paths should return typed errors.

Evidence:
- Sources/ChartKit/ContentView.swift:150 `fatalError("Unknown Chart Type")`

### 2. [Medium] Concurrency escape hatches need strict-concurrency review

Detached tasks, unchecked Sendable, unsafe isolation, and manual queue hops should have ownership notes and tests for cancellation or actor handoff behavior.

Evidence:
- Sources/ChartKit/Charts/BarCharts/SingleBar.swift:34 `DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.02) {`
- Sources/ChartKit/Charts/LineCharts/SingleLine.swift:72 `DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.02) {`
- Sources/ChartKit/Charts/AreaCharts/AreaSimple.swift:45 `DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.02) {`

### 3. [Low] Generated build artifacts exist in the package tree

Keep generated build metadata out of review scope and source commits unless a package intentionally vendors generated assets.

Evidence:
- .build
- .swiftpm

## Verification

- `swift package dump-package --package-path ChartKit`: passed
- Full `swift build`/`swift test` was not run during document generation; run the package-specific command before shipping behavior changes.

## Recommended Next Steps

1. Convert the Medium findings above into focused follow-up tasks with owner and verification command.
2. Expand tests around the specific evidence paths before changing behavior near them.
3. Keep this `REVIEW.md` current when package structure, dependencies, or risk posture changes.

## Review Limitations

- This is a static code review pass, not a full product walkthrough or security audit.
- Pattern matches are intentionally conservative and may include legitimate framework or test code that still deserves an explicit ownership note.
- Generated directories, dependency folders, and git metadata were excluded from evidence collection.
