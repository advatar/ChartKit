//
// Copyright © 2022 ChartKit.
// Open Source - MIT License

import SwiftUI

enum ChartCategory: String, CaseIterable, Hashable, Identifiable {
	case all
    case apple
    case line
    case bar
    case area
    case range
    case heatMap
    case point
    case health
    case clinical

	var id: String { self.rawValue }

	var sfSymbolName: String {
		switch self {
		case .all:
			return ""
        case .apple:
            return "applelogo"
        case .line:
            return "chart.xyaxis.line"
        case .bar:
            return "chart.bar.fill"
        case .area:
            return "triangle.fill"
        case .range:
            return "trapezoid.and.line.horizontal.fill"
        case .heatMap:
            return "checkerboard.rectangle"
        case .point:
            return "point.3.connected.trianglepath.dotted"
        case .health:
            return "heart.text.square.fill"
        case .clinical:
            return "cross.case.fill"
		}
	}
}

enum ChartType: String, Identifiable, CaseIterable {
    // Apple
    case heartBeat
    case oneDimensionalBar
    case screenTime

    // Line Charts
    case singleLine
    case singleLineLollipop
    case animatingLine
    case gradientLine
    case multiLine
    case linePoint

    // Bar Charts
    case singleBar
    case singleBarThreshold
    case twoBars
    case pyramid
    case timeSheetBar
    #if canImport(UIKit)
    case soundBar
    #endif
    case scrollingBar

    // Area Charts
    case areaSimple
    case stackedArea

    // Range Charts
    case rangeSimple
    case rangeHeartRate
    case candleStick

    // HeatMap Charts
    case customizeableHeatMap
    case gitContributions

    // Point Charts
    case scatter
    case vectorField

    // Apple Health Charts
    case healthSteps
    case healthHeartRate
    case healthCardioFitness
    case healthVitals
    case healthSleepStages
    case healthCycleTracking
    case healthMedicationEvents
    case healthWorkoutDetails

    // Clinical Health Records
    case clinicalLabResults
    case clinicalVitalSigns
    case clinicalBloodPressure
    case clinicalRecordsTimeline
    case clinicalNotesCoverage

	var id: String { self.rawValue }

    var title: String {
        switch self {
        case .heartBeat:
            return "Electrocardiograms (ECG)"
        case .oneDimensionalBar:
            return "iPhone Storage"
        case .screenTime:
            return "Screen Time"
        case .singleLine:
            return "Line Chart"
        case .singleLineLollipop:
            return "Line Chart with Lollipop"
        case .animatingLine:
            return "Animating Line"
        case .gradientLine:
            return "Line with changing gradient"
        case .multiLine:
            return "Line Charts"
        case .linePoint:
            return "Line Point"
        case .singleBar:
            return "Single Bar"
        case .singleBarThreshold:
            return "Single Bar with Threshold Rule Mark"
        case .twoBars:
            return "Two Bars"
        case .scrollingBar:
            return "Horizontal Scrolling Bar Chart"
        case .pyramid:
            return "Pyramid"
        case .timeSheetBar:
            return "Time Sheet Bar"
        #if canImport(UIKit)
        case .soundBar:
            return "Sound Bar"
        #endif
        case .areaSimple:
            return "Area Chart"
        case .stackedArea:
            return "Stacked Area Chart"
        case .rangeSimple:
            return "Range Chart"
        case .rangeHeartRate:
            return "Heart Rate Range Chart"
        case .candleStick:
            return "Candle Stick Chart"
        case .customizeableHeatMap:
            return "Customizable Heat Map"
        case .gitContributions:
            return "GitHub Contributions Graph"
        case .scatter:
            return "Scatter Chart"
        case .vectorField:
            return "Vector Field"
        case .healthSteps:
            return "Health Steps"
        case .healthHeartRate:
            return "Health Heart Rate"
        case .healthCardioFitness:
            return "Health Cardio Fitness"
        case .healthVitals:
            return "Health Vitals"
        case .healthSleepStages:
            return "Health Sleep Stages"
        case .healthCycleTracking:
            return "Health Cycle Tracking"
        case .healthMedicationEvents:
            return "Health Medications & Events"
        case .healthWorkoutDetails:
            return "Health Workout Details"
        case .clinicalLabResults:
            return "Clinical Lab Results"
        case .clinicalVitalSigns:
            return "Clinical Vital Signs"
        case .clinicalBloodPressure:
            return "Clinical Blood Pressure"
        case .clinicalRecordsTimeline:
            return "Clinical Records Timeline"
        case .clinicalNotesCoverage:
            return "Clinical Notes & Coverage"
        }
    }

    var category: ChartCategory {
        switch self {
        case .heartBeat, .screenTime, .oneDimensionalBar:
            return .apple
        case .singleLine, .singleLineLollipop, .animatingLine, .gradientLine, .multiLine, .linePoint:
            return .line
        case .singleBar, .singleBarThreshold, .twoBars, .pyramid, .timeSheetBar:
            return .bar
        #if canImport(UIKit)
        case .soundBar:
            return .bar
        #endif
        case .areaSimple, .stackedArea:
            return .area
        case .rangeSimple, .rangeHeartRate, .candleStick:
            return .range
        case .customizeableHeatMap, .gitContributions:
            return .heatMap
        case .scatter, .vectorField:
            return .point
        case .healthSteps, .healthHeartRate, .healthCardioFitness, .healthVitals, .healthSleepStages, .healthCycleTracking, .healthMedicationEvents, .healthWorkoutDetails:
            return .health
        case .clinicalLabResults, .clinicalVitalSigns, .clinicalBloodPressure, .clinicalRecordsTimeline, .clinicalNotesCoverage:
            return .clinical
        case .scrollingBar:
            return .bar
        }
    }

    var view: some View {
        overviewOrDetailView(isOverview: true)
    }
    
    var chartDescriptor: AXChartDescriptor? {
        // This is necessary since we use images for preview/overview
        // TODO: Use protocol conformance to remove manual switch necessity
        switch self {
        case .singleLine:
            return SingleLine(isOverview: true).makeChartDescriptor()
        case .singleLineLollipop:
            return SingleLineLollipop(isOverview: true).makeChartDescriptor()
        case .multiLine:
            return MultiLine(isOverview: true).makeChartDescriptor()
        case .heartBeat:
            return HeartBeat(isOverview: true).makeChartDescriptor()
        case .animatingLine:
            return AnimatedChart(x: 0, isOverview: true).makeChartDescriptor()
        case .singleBar:
            return SingleBar(isOverview: true).makeChartDescriptor()
        case .singleBarThreshold:
            return SingleBarThreshold(isOverview: true).makeChartDescriptor()
        case .twoBars:
            return TwoBars(isOverview: true).makeChartDescriptor()
        case .oneDimensionalBar:
            return OneDimensionalBar(isOverview: true).makeChartDescriptor()
        case .candleStick:
            return CandleStickChart(isOverview: true).makeChartDescriptor()
        case .timeSheetBar:
            return TimeSheetBar(isOverview: true).makeChartDescriptor()
        case .pyramid:
            return PyramidChart(isOverview: true).makeChartDescriptor()
        case .areaSimple:
            return AreaSimple(isOverview: true).makeChartDescriptor()
        case .stackedArea:
            return StackedArea(isOverview: true).makeChartDescriptor()
        case .rangeSimple:
            return RangeSimple(isOverview: true).makeChartDescriptor()
        case .rangeHeartRate:
            return HeartRateRangeChart(isOverview: true).makeChartDescriptor()
        case .customizeableHeatMap:
            return HeatMap(isOverview: true).makeChartDescriptor()
        case .scatter:
            return ScatterChart(isOverview: true).makeChartDescriptor()
        case .vectorField:
            return VectorField(isOverview: true).makeChartDescriptor()
        case .gradientLine:
            return GradientLine(isOverview: true).makeChartDescriptor()
        #if canImport(UIKit)
        case .soundBar:
            return SoundBars(isOverview: true).makeChartDescriptor()
        #endif
        case .linePoint:
            return LinePlot(isOverview: true).makeChartDescriptor()
        case .gitContributions:
            return GitHubContributionsGraph(isOverview: true).makeChartDescriptor()
        case .screenTime:
            // This graph mirrors Apple's implementation
            // each individual sub graph has it's own audio graph/descriptor
            fallthrough
        default:
            return nil

        }
    }

    var detailView: some View {
        overviewOrDetailView(isOverview: false)
    }

    @ViewBuilder
    private func overviewOrDetailView(isOverview: Bool) -> some View {
        switch self {
        case .oneDimensionalBar:
            OneDimensionalBar(isOverview: isOverview)
        case .screenTime:
            ScreenTime(isOverview: isOverview)
        case .singleLine:
            SingleLine(isOverview: isOverview)
        case .singleLineLollipop:
            SingleLineLollipop(isOverview: isOverview)
        case .heartBeat:
            HeartBeat(isOverview: isOverview)
        case .animatingLine:
            AnimatingLine(isOverview: isOverview)
        case .gradientLine:
            GradientLine(isOverview: isOverview)
        case .multiLine:
            MultiLine(isOverview: isOverview)
		case .linePoint:
			LinePlot(isOverview: isOverview)
        case .singleBar:
            SingleBar(isOverview: isOverview)
        case .scrollingBar:
            ScrollingBar(isOverview: isOverview)
        case .singleBarThreshold:
            SingleBarThreshold(isOverview: isOverview)
        case .twoBars:
            TwoBars(isOverview: isOverview)
        case .pyramid:
            PyramidChart(isOverview: isOverview)
        case .timeSheetBar:
            TimeSheetBar(isOverview: isOverview)
        #if canImport(UIKit)
        case .soundBar:
            SoundBars(isOverview: isOverview)
        #endif
        case .areaSimple:
            AreaSimple(isOverview: isOverview)
        case .stackedArea:
            StackedArea(isOverview: isOverview)
        case .rangeSimple:
            RangeSimple(isOverview: isOverview)
        case .rangeHeartRate:
            HeartRateRangeChart(isOverview: isOverview)
        case .candleStick:
            CandleStickChart(isOverview: isOverview)
        case .customizeableHeatMap:
            HeatMap(isOverview: isOverview)
        case .gitContributions:
            GitHubContributionsGraph(isOverview: isOverview)
        case .scatter:
            ScatterChart(isOverview: isOverview)
        case .vectorField:
            VectorField(isOverview: isOverview)
        case .healthSteps:
            HealthQuantityTimelineChart(isOverview: isOverview, style: .cumulative)
        case .healthHeartRate:
            HealthQuantityTimelineChart(isOverview: isOverview, style: .discreteRange)
        case .healthCardioFitness:
            HealthRangeBandChart(isOverview: isOverview, kind: .cardioFitness)
        case .healthVitals:
            HealthRangeBandChart(isOverview: isOverview, kind: .vitals)
        case .healthSleepStages:
            HealthSleepStagesChart(isOverview: isOverview)
        case .healthCycleTracking:
            HealthCycleTimelineChart(isOverview: isOverview)
        case .healthMedicationEvents:
            HealthMedicationEventsTimeline(isOverview: isOverview)
        case .healthWorkoutDetails:
            HealthWorkoutDetailChart(isOverview: isOverview)
        case .clinicalLabResults:
            ClinicalObservationChart(isOverview: isOverview, kind: .lab)
        case .clinicalVitalSigns:
            ClinicalObservationChart(isOverview: isOverview, kind: .vital)
        case .clinicalBloodPressure:
            ClinicalBloodPressureChart(isOverview: isOverview)
        case .clinicalRecordsTimeline:
            ClinicalRecordsTimelineChart(isOverview: isOverview, kind: .records)
        case .clinicalNotesCoverage:
            ClinicalRecordsTimelineChart(isOverview: isOverview, kind: .notesAndCoverage)
        }
    }
}
