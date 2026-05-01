//
// Copyright © 2026 ChartKit.
// Open Source - MIT License

import Foundation
import SwiftUI

enum HealthChartFixtures {
    static let calendar = Calendar(identifier: .gregorian)

    static func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 0, minute: Int = 0) -> Date {
        DateComponents(calendar: calendar, year: year, month: month, day: day, hour: hour, minute: minute).date ?? Date()
    }

    static let steps: [HealthQuantityBucket] = (0..<30).map { index in
        let start = date(2026, 4, 1 + index)
        return HealthQuantityBucket(
            start: start,
            end: calendar.date(byAdding: .day, value: 1, to: start) ?? start,
            value: [6200, 8400, 5200, 10400, 9200, 3000, 11800, 7900, 6100, 9500][index % 10],
            minimum: nil,
            maximum: nil,
            unit: "steps",
            source: index % 5 == 0 ? "iPhone" : "Apple Watch"
        )
    }

    static let heartRate: [HealthQuantityBucket] = (0..<24).map { index in
        let start = date(2026, 4, 30, hour: index)
        let average = 61 + Double((index * 7) % 28)
        return HealthQuantityBucket(
            start: start,
            end: calendar.date(byAdding: .hour, value: 1, to: start) ?? start,
            value: average,
            minimum: average - Double(5 + index % 4),
            maximum: average + Double(7 + index % 6),
            unit: "BPM",
            source: "Apple Watch"
        )
    }

    static let cardioFitness: [ClinicalObservationPoint] = makeCardioFitness()

    static let cardioBands = [
        HealthRangeBand(name: "Low", lowerBound: 20, upperBound: 30, color: .red),
        HealthRangeBand(name: "Below Avg", lowerBound: 30, upperBound: 36, color: .orange),
        HealthRangeBand(name: "Above Avg", lowerBound: 36, upperBound: 44, color: .green),
        HealthRangeBand(name: "High", lowerBound: 44, upperBound: 52, color: .blue)
    ]

    static let vitals: [ClinicalObservationPoint] = makeVitals()

    static let sleep: [SleepStageSegment] = [
        .init(start: date(2026, 4, 30, hour: 22, minute: 38), end: date(2026, 4, 30, hour: 22, minute: 52), stage: .awake),
        .init(start: date(2026, 4, 30, hour: 22, minute: 52), end: date(2026, 4, 30, hour: 23, minute: 40), stage: .core),
        .init(start: date(2026, 4, 30, hour: 23, minute: 40), end: date(2026, 5, 1, hour: 0, minute: 24), stage: .deep),
        .init(start: date(2026, 5, 1, hour: 0, minute: 24), end: date(2026, 5, 1, hour: 1, minute: 18), stage: .core),
        .init(start: date(2026, 5, 1, hour: 1, minute: 18), end: date(2026, 5, 1, hour: 1, minute: 44), stage: .rem),
        .init(start: date(2026, 5, 1, hour: 1, minute: 44), end: date(2026, 5, 1, hour: 3, minute: 15), stage: .core),
        .init(start: date(2026, 5, 1, hour: 3, minute: 15), end: date(2026, 5, 1, hour: 3, minute: 28), stage: .awake),
        .init(start: date(2026, 5, 1, hour: 3, minute: 28), end: date(2026, 5, 1, hour: 4, minute: 50), stage: .core),
        .init(start: date(2026, 5, 1, hour: 4, minute: 50), end: date(2026, 5, 1, hour: 5, minute: 33), stage: .rem),
        .init(start: date(2026, 5, 1, hour: 5, minute: 33), end: date(2026, 5, 1, hour: 6, minute: 42), stage: .core)
    ]

    static let cycleDays: [CycleTrackingDay] = (0..<28).map { index in
        CycleTrackingDay(
            date: date(2026, 5, 1 + index),
            isPredictedPeriod: (22...26).contains(index),
            isFertileWindow: (9...14).contains(index),
            isLikelyOvulation: index == 14,
            isLoggedPeriod: (0...4).contains(index),
            hasLoggedInfo: [2, 5, 13, 17, 21].contains(index)
        )
    }

    static let medicationEvents: [HealthEvent] = [
        .init(date: date(2026, 5, 1, hour: 7), title: "Levothyroxine", subtitle: "75 mcg", state: .taken),
        .init(date: date(2026, 5, 1, hour: 8), title: "Vitamin D", subtitle: "1000 IU", state: .taken),
        .init(date: date(2026, 5, 1, hour: 21), title: "Magnesium", subtitle: "250 mg", state: .scheduled),
        .init(date: date(2026, 4, 29, hour: 10), title: "High Heart Rate", subtitle: "Detected while inactive", state: .detected),
        .init(date: date(2026, 4, 26, hour: 18), title: "Headache", subtitle: "Symptom logged", state: .resolved)
    ]

    static let workout: [WorkoutMetricPoint] = makeWorkout()

    static let a1c: [ClinicalObservationPoint] = [
        .init(date: date(2024, 11, 14), value: 5.7, unit: "%", name: "Hemoglobin A1C", source: "North Clinic", interpretation: "High"),
        .init(date: date(2025, 2, 20), value: 5.5, unit: "%", name: "Hemoglobin A1C", source: "North Clinic", interpretation: nil),
        .init(date: date(2025, 8, 3), value: 5.4, unit: "%", name: "Hemoglobin A1C", source: "City Medical", interpretation: nil),
        .init(date: date(2026, 3, 11), value: 5.2, unit: "%", name: "Hemoglobin A1C", source: "City Medical", interpretation: nil)
    ]

    static let cholesterol: [ClinicalObservationPoint] = [
        .init(date: date(2024, 10, 12), value: 212, unit: "mg/dL", name: "Total Cholesterol", source: "North Clinic", interpretation: "High"),
        .init(date: date(2025, 3, 15), value: 196, unit: "mg/dL", name: "Total Cholesterol", source: "North Clinic", interpretation: nil),
        .init(date: date(2025, 9, 4), value: 184, unit: "mg/dL", name: "Total Cholesterol", source: "City Medical", interpretation: nil),
        .init(date: date(2026, 3, 9), value: 176, unit: "mg/dL", name: "Total Cholesterol", source: "City Medical", interpretation: nil)
    ]

    static let bloodPressure: [ClinicalBloodPressureReading] = [
        .init(date: date(2024, 9, 3), systolic: 132, diastolic: 84, source: "North Clinic", interpretation: "Elevated"),
        .init(date: date(2025, 1, 8), systolic: 126, diastolic: 79, source: "North Clinic", interpretation: nil),
        .init(date: date(2025, 7, 22), systolic: 121, diastolic: 77, source: "City Medical", interpretation: nil),
        .init(date: date(2026, 2, 18), systolic: 118, diastolic: 74, source: "City Medical", interpretation: nil)
    ]

    static let clinicalTimeline: [ClinicalTimelineRecord] = [
        .init(date: date(2026, 3, 15), title: "Influenza Vaccine", subtitle: "Dose administered", source: "City Medical", status: "Completed", tint: .green),
        .init(date: date(2026, 1, 22), title: "Atorvastatin", subtitle: "20 mg tablet, daily", source: "North Clinic", status: "Active", tint: .blue),
        .init(date: date(2025, 11, 9), title: "Essential hypertension", subtitle: "Problem list entry", source: "North Clinic", status: "Active", tint: .orange),
        .init(date: date(2025, 8, 2), title: "Appendectomy", subtitle: "Procedure record", source: "City Hospital", status: "Completed", tint: .purple),
        .init(date: date(2024, 5, 19), title: "Penicillin", subtitle: "Rash reaction", source: "North Clinic", status: "Allergy", tint: .red)
    ]

    static let notesAndCoverage: [ClinicalTimelineRecord] = [
        .init(date: date(2026, 3, 18), title: "Primary Care Visit", subtitle: "Progress note from annual physical", source: "City Medical", status: "Clinical Note", tint: .blue),
        .init(date: date(2026, 2, 1), title: "Advatar Health PPO", subtitle: "Coverage active through Dec 31, 2026", source: "Example Payer", status: "Coverage", tint: .green),
        .init(date: date(2025, 10, 4), title: "Cardiology Consultation", subtitle: "Specialist note and care plan", source: "North Clinic", status: "Clinical Note", tint: .indigo)
    ]

    private static func makeCardioFitness() -> [ClinicalObservationPoint] {
        (0..<12).map { index in
            let value = 31 + Double(index) * 0.7 + Double(index % 3)
            let interpretation: String
            if index < 3 {
                interpretation = "Low"
            } else if index < 8 {
                interpretation = "Below Average"
            } else {
                interpretation = "Above Average"
            }

            return ClinicalObservationPoint(
                date: date(2025, 5 + index, 15),
                value: value,
                unit: "mL/kg/min",
                name: "Cardio Fitness",
                source: "Apple Watch",
                interpretation: interpretation
            )
        }
    }

    private static func makeVitals() -> [ClinicalObservationPoint] {
        (0..<14).map { index in
            let value = 58 + Double((index * 3) % 14)
            let interpretation = (56...70).contains(Int(value)) ? "Typical" : "Outside typical range"
            return ClinicalObservationPoint(
                date: date(2026, 4, 17 + index),
                value: value,
                unit: "BPM",
                name: "Sleeping Heart Rate",
                source: "Apple Watch",
                interpretation: interpretation
            )
        }
    }

    private static func makeWorkout() -> [WorkoutMetricPoint] {
        stride(from: 0, through: 48, by: 3).map { minute in
            let elapsedMinutes = Double(minute)
            let heartRate = 118 + Double((minute * 5) % 46)
            let pace = 5.8 - Double((minute / 3) % 5) * 0.12
            let elevation = 12 + sin(Double(minute) / 8) * 18
            return WorkoutMetricPoint(
                elapsedMinutes: elapsedMinutes,
                heartRate: heartRate,
                pace: pace,
                elevation: elevation
            )
        }
    }
}
