//
// Copyright © 2026 ChartKit.
// Open Source - MIT License

import SwiftUI

enum HealthRangeScope: String, CaseIterable, Identifiable {
    case day = "D"
    case week = "W"
    case month = "M"
    case sixMonths = "6M"
    case year = "Y"

    var id: String { rawValue }
}

struct HealthQuantityBucket: Identifiable {
    let id = UUID()
    let start: Date
    let end: Date
    let value: Double
    let minimum: Double?
    let maximum: Double?
    let unit: String
    let source: String
}

struct HealthRangeBand: Identifiable {
    let id = UUID()
    let name: String
    let lowerBound: Double
    let upperBound: Double
    let color: Color
}

enum HealthSleepStage: String, CaseIterable, Identifiable {
    case awake = "Awake"
    case rem = "REM"
    case core = "Core"
    case deep = "Deep"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .awake:
            return .orange
        case .rem:
            return .cyan
        case .core:
            return .indigo
        case .deep:
            return .purple
        }
    }
}

struct SleepStageSegment: Identifiable {
    let id = UUID()
    let start: Date
    let end: Date
    let stage: HealthSleepStage
}

struct CycleTrackingDay: Identifiable {
    let id = UUID()
    let date: Date
    let isPredictedPeriod: Bool
    let isFertileWindow: Bool
    let isLikelyOvulation: Bool
    let isLoggedPeriod: Bool
    let hasLoggedInfo: Bool
}

enum HealthEventState: String {
    case scheduled = "Scheduled"
    case taken = "Taken"
    case skipped = "Skipped"
    case detected = "Detected"
    case resolved = "Resolved"

    var color: Color {
        switch self {
        case .scheduled:
            return .secondary
        case .taken:
            return .green
        case .skipped:
            return .orange
        case .detected:
            return .red
        case .resolved:
            return .blue
        }
    }
}

struct HealthEvent: Identifiable {
    let id = UUID()
    let date: Date
    let title: String
    let subtitle: String
    let state: HealthEventState
}

struct WorkoutMetricPoint: Identifiable {
    let id = UUID()
    let elapsedMinutes: Double
    let heartRate: Double
    let pace: Double
    let elevation: Double
}

struct ClinicalObservationPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let unit: String
    let name: String
    let source: String
    let interpretation: String?
}

struct ClinicalBloodPressureReading: Identifiable {
    let id = UUID()
    let date: Date
    let systolic: Double
    let diastolic: Double
    let source: String
    let interpretation: String?
}

struct ClinicalTimelineRecord: Identifiable {
    let id = UUID()
    let date: Date
    let title: String
    let subtitle: String
    let source: String
    let status: String
    let tint: Color
}
