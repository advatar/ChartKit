//
// Copyright © 2026 ChartKit.
// Open Source - MIT License

import Charts
import SwiftUI

private extension Date {
    var healthDayLabel: String {
        formatted(.dateTime.month(.abbreviated).day())
    }
}

private struct HealthSummaryHeader: View {
    let title: String
    let value: String
    let subtitle: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(value)
                .font(.system(.largeTitle, design: .rounded).weight(.semibold))
                .foregroundStyle(tint)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct HealthRangePicker: View {
    @Binding var scope: HealthRangeScope

    var body: some View {
        Picker("Range", selection: $scope) {
            ForEach(HealthRangeScope.allCases) { scope in
                Text(scope.rawValue).tag(scope)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct HealthQuantityTimelineChart: View {
    enum Style {
        case cumulative
        case discreteRange
    }

    var isOverview: Bool
    let style: Style

    @State private var scope: HealthRangeScope = .month
    @State private var selectedDate: Date?

    private var data: [HealthQuantityBucket] {
        switch style {
        case .cumulative:
            return HealthChartFixtures.steps
        case .discreteRange:
            return HealthChartFixtures.heartRate
        }
    }

    private var title: String {
        switch style {
        case .cumulative:
            return "Steps"
        case .discreteRange:
            return "Heart Rate"
        }
    }

    private var tint: Color {
        switch style {
        case .cumulative:
            return .pink
        case .discreteRange:
            return .red
        }
    }

    private var selectedBucket: HealthQuantityBucket {
        guard
            let selectedDate,
            let nearest = data.min(by: { abs($0.start.timeIntervalSince(selectedDate)) < abs($1.start.timeIntervalSince(selectedDate)) })
        else {
            return data.last!
        }
        return nearest
    }

    var body: some View {
        if isOverview {
            chart
        } else {
            List {
                Section {
                    HealthSummaryHeader(
                        title: title,
                        value: "\(Int(selectedBucket.value)) \(selectedBucket.unit)",
                        subtitle: "\(selectedBucket.start.healthDayLabel) · \(selectedBucket.source)",
                        tint: tint
                    )
                    HealthRangePicker(scope: $scope)
                    chart
                }
            }
            .navigationBarTitle(title, displayMode: .inline)
        }
    }

    @ViewBuilder
    private var chart: some View {
        Chart {
            ForEach(data) { bucket in
                switch style {
                case .cumulative:
                    BarMark(
                        x: .value("Date", bucket.start),
                        y: .value(title, bucket.value)
                    )
                    .clipShape(Capsule())
                    .foregroundStyle(tint.gradient)
                case .discreteRange:
                    BarMark(
                        x: .value("Time", bucket.start),
                        yStart: .value("Low", bucket.minimum ?? bucket.value),
                        yEnd: .value("High", bucket.maximum ?? bucket.value),
                        width: .fixed(8)
                    )
                    .clipShape(Capsule())
                    .foregroundStyle(tint.opacity(0.55).gradient)

                    PointMark(
                        x: .value("Time", bucket.start),
                        y: .value("Average", bucket.value)
                    )
                    .foregroundStyle(tint)
                    .symbolSize(isOverview ? 14 : 24)
                }

                if !isOverview, selectedBucket.id == bucket.id {
                    RuleMark(x: .value("Selected", bucket.start))
                        .foregroundStyle(.secondary.opacity(0.45))
                }
            }
        }
        .chartXAxis(isOverview ? .hidden : .automatic)
        .chartYAxis(isOverview ? .hidden : .automatic)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let origin = geometry[proxy.plotAreaFrame].origin
                                let location = value.location.x - origin.x
                                selectedDate = proxy.value(atX: location)
                            }
                    )
            }
        }
        .frame(height: isOverview ? Constants.previewChartHeight : Constants.detailChartHeight)
    }
}

struct HealthRangeBandChart: View {
    enum Kind {
        case cardioFitness
        case vitals
    }

    var isOverview: Bool
    let kind: Kind

    @State private var scope: HealthRangeScope = .year

    private var observations: [ClinicalObservationPoint] {
        switch kind {
        case .cardioFitness:
            return HealthChartFixtures.cardioFitness
        case .vitals:
            return HealthChartFixtures.vitals
        }
    }

    private var bands: [HealthRangeBand] {
        switch kind {
        case .cardioFitness:
            return HealthChartFixtures.cardioBands
        case .vitals:
            return [HealthRangeBand(name: "Typical", lowerBound: 56, upperBound: 70, color: .blue)]
        }
    }

    private var title: String {
        switch kind {
        case .cardioFitness:
            return "Cardio Fitness"
        case .vitals:
            return "Vitals Typical Range"
        }
    }

    private var latest: ClinicalObservationPoint { observations.last! }

    var body: some View {
        if isOverview {
            chart
        } else {
            List {
                Section {
                    HealthSummaryHeader(
                        title: title,
                        value: "\(String(format: "%.1f", latest.value)) \(latest.unit)",
                        subtitle: "\(latest.date.healthDayLabel) · \(latest.interpretation ?? latest.source)",
                        tint: kind == .cardioFitness ? .green : .blue
                    )
                    HealthRangePicker(scope: $scope)
                    chart
                }
            }
            .navigationBarTitle(title, displayMode: .inline)
        }
    }

    private var chart: some View {
        Chart {
            ForEach(bands) { band in
                RectangleMark(
                    xStart: .value("Start", observations.first?.date ?? Date()),
                    xEnd: .value("End", observations.last?.date ?? Date()),
                    yStart: .value("Lower", band.lowerBound),
                    yEnd: .value("Upper", band.upperBound)
                )
                .foregroundStyle(band.color.opacity(kind == .vitals ? 0.16 : 0.12))
            }

            ForEach(observations) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value(point.name, point.value)
                )
                .foregroundStyle(kind == .cardioFitness ? .green : .blue)
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", point.date),
                    y: .value(point.name, point.value)
                )
                .foregroundStyle(point.interpretation?.contains("Outside") == true ? .orange : (kind == .cardioFitness ? .green : .blue))
                .symbolSize(isOverview ? 16 : 32)
            }
        }
        .chartXAxis(isOverview ? .hidden : .automatic)
        .chartYAxis(isOverview ? .hidden : .automatic)
        .frame(height: isOverview ? Constants.previewChartHeight : Constants.detailChartHeight)
    }
}

struct HealthSleepStagesChart: View {
    var isOverview: Bool

    private var asleepDuration: TimeInterval {
        HealthChartFixtures.sleep
            .filter { $0.stage != .awake }
            .reduce(0) { $0 + $1.end.timeIntervalSince($1.start) }
    }

    var body: some View {
        if isOverview {
            chart
        } else {
            List {
                Section {
                    HealthSummaryHeader(
                        title: "Sleep",
                        value: asleepDuration.durationDescription,
                        subtitle: "Stages · Awake, REM, Core, Deep",
                        tint: .indigo
                    )
                    chart
                }
            }
            .navigationBarTitle("Sleep", displayMode: .inline)
        }
    }

    private var chart: some View {
        Chart(HealthChartFixtures.sleep) { segment in
            BarMark(
                xStart: .value("Start", segment.start),
                xEnd: .value("End", segment.end),
                y: .value("Stage", segment.stage.rawValue),
                height: .fixed(isOverview ? 14 : 22)
            )
            .clipShape(Capsule())
            .foregroundStyle(segment.stage.color.gradient)
        }
        .chartYScale(domain: HealthSleepStage.allCases.map(\.rawValue).reversed())
        .chartXAxis(isOverview ? .hidden : .automatic)
        .chartYAxis(isOverview ? .hidden : .automatic)
        .frame(height: isOverview ? Constants.previewChartHeight : Constants.detailChartHeight)
    }
}

struct HealthCycleTimelineChart: View {
    var isOverview: Bool
    @State private var selectedDay = HealthChartFixtures.cycleDays[2]

    var body: some View {
        if isOverview {
            timeline
        } else {
            List {
                Section {
                    HealthSummaryHeader(
                        title: "Cycle Tracking",
                        value: selectedDay.date.formatted(.dateTime.month(.wide).day()),
                        subtitle: selectedSummary,
                        tint: .pink
                    )
                    timeline
                }
            }
            .navigationBarTitle("Cycle Tracking", displayMode: .inline)
        }
    }

    private var selectedSummary: String {
        var states: [String] = []
        if selectedDay.isLoggedPeriod { states.append("Period logged") }
        if selectedDay.isPredictedPeriod { states.append("Predicted period") }
        if selectedDay.isFertileWindow { states.append("Fertile window") }
        if selectedDay.isLikelyOvulation { states.append("Likely ovulation") }
        if selectedDay.hasLoggedInfo { states.append("Logged info") }
        return states.isEmpty ? "No cycle data" : states.joined(separator: " · ")
    }

    private var timeline: some View {
        ScrollView(.horizontal, showsIndicators: !isOverview) {
            HStack(spacing: 10) {
                ForEach(HealthChartFixtures.cycleDays) { day in
                    Button {
                        selectedDay = day
                    } label: {
                        VStack(spacing: 6) {
                            Text(day.date.formatted(.dateTime.weekday(.narrow)))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            ZStack {
                                if day.isFertileWindow {
                                    Capsule()
                                        .fill(Color.cyan.opacity(0.18))
                                        .frame(width: 38, height: 24)
                                }
                                if day.isLikelyOvulation {
                                    Capsule()
                                        .stroke(Color.purple.opacity(0.75), lineWidth: 2)
                                        .frame(width: 38, height: 24)
                                }
                                Circle()
                                    .fill(day.isLoggedPeriod ? Color.red : day.isPredictedPeriod ? Color.red.opacity(0.18) : Color.secondary.opacity(0.1))
                                    .frame(width: 24, height: 24)
                                    .overlay {
                                        if selectedDay.id == day.id {
                                            Circle().stroke(.primary, lineWidth: 2)
                                        }
                                    }
                                if day.hasLoggedInfo {
                                    Circle()
                                        .fill(Color.purple)
                                        .frame(width: 5, height: 5)
                                        .offset(y: 18)
                                }
                            }
                            Text(day.date.formatted(.dateTime.day()))
                                .font(.caption)
                                .foregroundStyle(.primary)
                        }
                        .frame(width: 42, height: isOverview ? 72 : 92)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
        .frame(height: isOverview ? Constants.previewChartHeight : 120)
    }
}

struct HealthMedicationEventsTimeline: View {
    var isOverview: Bool

    var body: some View {
        if isOverview {
            eventRows
        } else {
            List {
                Section {
                    HealthSummaryHeader(
                        title: "Medications & Events",
                        value: "\(HealthChartFixtures.medicationEvents.count) events",
                        subtitle: "Scheduled, taken, skipped, detected, and resolved",
                        tint: .green
                    )
                    eventRows
                }
            }
            .navigationBarTitle("Medications & Events", displayMode: .inline)
        }
    }

    private var eventRows: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(HealthChartFixtures.medicationEvents.prefix(isOverview ? 4 : 10)) { event in
                TimelineRow(date: event.date, title: event.title, subtitle: "\(event.subtitle) · \(event.state.rawValue)", source: nil, tint: event.state.color)
            }
        }
        .frame(height: isOverview ? Constants.previewChartHeight : nil, alignment: .top)
    }
}

struct HealthWorkoutDetailChart: View {
    var isOverview: Bool

    var body: some View {
        if isOverview {
            heartRateChart
        } else {
            List {
                Section {
                    HealthSummaryHeader(
                        title: "Outdoor Run",
                        value: "48:00",
                        subtitle: "Heart rate, pace, elevation",
                        tint: .orange
                    )
                    heartRateChart
                    paceElevationChart
                }
            }
            .navigationBarTitle("Workout Details", displayMode: .inline)
        }
    }

    private var heartRateChart: some View {
        Chart(HealthChartFixtures.workout) { point in
            LineMark(
                x: .value("Minute", point.elapsedMinutes),
                y: .value("Heart Rate", point.heartRate)
            )
            .foregroundStyle(.red.gradient)
            .interpolationMethod(.catmullRom)
        }
        .chartXAxis(isOverview ? .hidden : .automatic)
        .chartYAxis(isOverview ? .hidden : .automatic)
        .frame(height: isOverview ? Constants.previewChartHeight : 170)
    }

    private var paceElevationChart: some View {
        Chart {
            ForEach(HealthChartFixtures.workout) { point in
                LineMark(
                    x: .value("Minute", point.elapsedMinutes),
                    y: .value("Pace", point.pace)
                )
                .foregroundStyle(.blue.gradient)

                AreaMark(
                    x: .value("Minute", point.elapsedMinutes),
                    y: .value("Elevation", point.elevation)
                )
                .foregroundStyle(.green.opacity(0.18).gradient)
            }
        }
        .frame(height: 170)
    }
}

struct ClinicalObservationChart: View {
    var isOverview: Bool
    let kind: Kind

    enum Kind {
        case lab
        case vital
    }

    private var data: [ClinicalObservationPoint] {
        switch kind {
        case .lab:
            return HealthChartFixtures.a1c
        case .vital:
            return HealthChartFixtures.cholesterol
        }
    }

    private var title: String { data.first?.name ?? "Clinical Observation" }
    private var latest: ClinicalObservationPoint { data.last! }

    var body: some View {
        if isOverview {
            chart
        } else {
            List {
                Section {
                    HealthSummaryHeader(
                        title: title,
                        value: "\(String(format: kind == .lab ? "%.1f" : "%.0f", latest.value)) \(latest.unit)",
                        subtitle: "\(latest.date.healthDayLabel) · \(latest.source)",
                        tint: kind == .lab ? .purple : .teal
                    )
                    chart
                }
            }
            .navigationBarTitle(title, displayMode: .inline)
        }
    }

    private var chart: some View {
        Chart {
            if kind == .lab {
                RectangleMark(
                    xStart: .value("Start", data.first?.date ?? Date()),
                    xEnd: .value("End", data.last?.date ?? Date()),
                    yStart: .value("Normal Low", 4.0),
                    yEnd: .value("Normal High", 5.6)
                )
                .foregroundStyle(.green.opacity(0.14))
            } else {
                RuleMark(y: .value("Recommended", 200))
                    .foregroundStyle(.orange)
                    .lineStyle(.init(lineWidth: 1, dash: [4]))
            }

            ForEach(data) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value(point.name, point.value)
                )
                .foregroundStyle((kind == .lab ? Color.purple : Color.teal).gradient)

                PointMark(
                    x: .value("Date", point.date),
                    y: .value(point.name, point.value)
                )
                .foregroundStyle(point.interpretation == nil ? (kind == .lab ? .purple : .teal) : .orange)
            }
        }
        .chartXAxis(isOverview ? .hidden : .automatic)
        .chartYAxis(isOverview ? .hidden : .automatic)
        .frame(height: isOverview ? Constants.previewChartHeight : Constants.detailChartHeight)
    }
}

struct ClinicalBloodPressureChart: View {
    var isOverview: Bool

    private var latest: ClinicalBloodPressureReading { HealthChartFixtures.bloodPressure.last! }

    var body: some View {
        if isOverview {
            chart
        } else {
            List {
                Section {
                    HealthSummaryHeader(
                        title: "Blood Pressure",
                        value: "\(Int(latest.systolic))/\(Int(latest.diastolic)) mmHg",
                        subtitle: "\(latest.date.healthDayLabel) · \(latest.source)",
                        tint: .red
                    )
                    chart
                }
            }
            .navigationBarTitle("Blood Pressure", displayMode: .inline)
        }
    }

    private var chart: some View {
        Chart {
            RectangleMark(
                xStart: .value("Start", HealthChartFixtures.bloodPressure.first?.date ?? Date()),
                xEnd: .value("End", HealthChartFixtures.bloodPressure.last?.date ?? Date()),
                yStart: .value("Normal", 60),
                yEnd: .value("Elevated", 120)
            )
            .foregroundStyle(.green.opacity(0.10))

            ForEach(HealthChartFixtures.bloodPressure) { reading in
                BarMark(
                    x: .value("Date", reading.date),
                    yStart: .value("Diastolic", reading.diastolic),
                    yEnd: .value("Systolic", reading.systolic),
                    width: .fixed(8)
                )
                .clipShape(Capsule())
                .foregroundStyle(.red.opacity(0.35))

                PointMark(x: .value("Date", reading.date), y: .value("Systolic", reading.systolic))
                    .foregroundStyle(.red)
                PointMark(x: .value("Date", reading.date), y: .value("Diastolic", reading.diastolic))
                    .foregroundStyle(.blue)
            }
        }
        .chartXAxis(isOverview ? .hidden : .automatic)
        .chartYAxis(isOverview ? .hidden : .automatic)
        .frame(height: isOverview ? Constants.previewChartHeight : Constants.detailChartHeight)
    }
}

struct ClinicalRecordsTimelineChart: View {
    enum Kind {
        case records
        case notesAndCoverage
    }

    var isOverview: Bool
    let kind: Kind

    private var data: [ClinicalTimelineRecord] {
        switch kind {
        case .records:
            return HealthChartFixtures.clinicalTimeline
        case .notesAndCoverage:
            return HealthChartFixtures.notesAndCoverage
        }
    }

    private var title: String {
        switch kind {
        case .records:
            return "Clinical Records"
        case .notesAndCoverage:
            return "Notes & Coverage"
        }
    }

    var body: some View {
        if isOverview {
            rows
        } else {
            List {
                Section {
                    HealthSummaryHeader(
                        title: title,
                        value: "\(data.count) records",
                        subtitle: "FHIR-backed Health Records",
                        tint: .blue
                    )
                    rows
                }
            }
            .navigationBarTitle(title, displayMode: .inline)
        }
    }

    private var rows: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(data.prefix(isOverview ? 4 : 12)) { record in
                TimelineRow(date: record.date, title: record.title, subtitle: "\(record.status) · \(record.subtitle)", source: record.source, tint: record.tint)
            }
        }
        .frame(height: isOverview ? Constants.previewChartHeight : nil, alignment: .top)
    }
}

private struct TimelineRow: View {
    let date: Date
    let title: String
    let subtitle: String
    let source: String?
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(spacing: 2) {
                Circle()
                    .fill(tint)
                    .frame(width: 10, height: 10)
                Rectangle()
                    .fill(tint.opacity(0.25))
                    .frame(width: 2, height: 28)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(source == nil ? date.healthDayLabel : "\(date.healthDayLabel) · \(source!)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
