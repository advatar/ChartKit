//
// Copyright © 2026 ChartKit.
// Open Source - MIT License

import Charts
import SwiftUI

public struct ClinicalTrendChartPoint: Identifiable, Equatable {
    public let id: String
    public let date: Date
    public let value: Double
    public let renderedValue: String

    public init(id: String, date: Date, value: Double, renderedValue: String) {
        self.id = id
        self.date = date
        self.value = value
        self.renderedValue = renderedValue
    }
}

public struct ClinicalTrendReferenceBand: Equatable {
    public let low: Double
    public let high: Double

    public init(low: Double, high: Double) {
        self.low = low
        self.high = high
    }
}

public enum ClinicalTrendXAxisLabelStyle {
    case monthDay
    case month
    case year
}

@available(iOS 17.0, macOS 14.0, *)
public struct ClinicalMetricTrendChart: View {
    private let points: [ClinicalTrendChartPoint]
    private let selectedPoint: ClinicalTrendChartPoint?
    private let referenceBand: ClinicalTrendReferenceBand?
    private let visibleDomainLength: TimeInterval?
    private let usesYearAxisLabels: Bool
    private let axisLabelStyle: ClinicalTrendXAxisLabelStyle
    private let accentColor: Color

    @Binding private var selectedDate: Date?
    @Binding private var scrollPosition: Date

    public init(
        points: [ClinicalTrendChartPoint],
        selectedPoint: ClinicalTrendChartPoint?,
        referenceBand: ClinicalTrendReferenceBand?,
        visibleDomainLength: TimeInterval?,
        usesYearAxisLabels: Bool,
        axisLabelStyle: ClinicalTrendXAxisLabelStyle,
        accentColor: Color,
        selectedDate: Binding<Date?>,
        scrollPosition: Binding<Date>
    ) {
        self.points = points.sorted { $0.date < $1.date }
        self.selectedPoint = selectedPoint
        self.referenceBand = referenceBand
        self.visibleDomainLength = visibleDomainLength
        self.usesYearAxisLabels = usesYearAxisLabels
        self.axisLabelStyle = axisLabelStyle
        self.accentColor = accentColor
        _selectedDate = selectedDate
        _scrollPosition = scrollPosition
    }

    public var body: some View {
        if let visibleDomainLength {
            baseChart
                .chartScrollableAxes(.horizontal)
                .chartXVisibleDomain(length: visibleDomainLength)
                .chartScrollPosition(x: $scrollPosition)
        } else {
            baseChart
        }
    }

    private var baseChart: some View {
        Chart {
            if let referenceBand, let domain {
                RectangleMark(
                    xStart: .value("Start", domain.lowerBound),
                    xEnd: .value("End", domain.upperBound),
                    yStart: .value("Reference Low", referenceBand.low),
                    yEnd: .value("Reference High", referenceBand.high)
                )
                .foregroundStyle(accentColor.opacity(0.08))
            }

            ForEach(points) { point in
                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    .linearGradient(
                        colors: [
                            accentColor.opacity(0.28),
                            accentColor.opacity(0.02)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .foregroundStyle(accentColor)
            }

            if let latestPoint {
                PointMark(
                    x: .value("Date", latestPoint.date),
                    y: .value("Value", latestPoint.value)
                )
                .symbolSize(45)
                .foregroundStyle(accentColor.opacity(selectedDate == nil ? 1 : 0.35))
            }

            if let selectedPoint {
                RuleMark(x: .value("Selected Date", selectedPoint.date))
                    .foregroundStyle(.secondary.opacity(0.35))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .annotation(position: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(selectedPoint.renderedValue)
                                .font(.caption.weight(.semibold))
                                .monospacedDigit()
                            Text(selectedPoint.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                PointMark(
                    x: .value("Selected Date", selectedPoint.date),
                    y: .value("Selected Value", selectedPoint.value)
                )
                .symbolSize(80)
                .foregroundStyle(accentColor)
            }
        }
        .frame(minHeight: 260)
        .chartXSelection(value: $selectedDate)
        .chartXAxis {
            if usesYearAxisLabels {
                AxisMarks(values: .stride(by: .year)) { value in
                    AxisGridLine()
                        .foregroundStyle(.quaternary)
                    AxisTick()
                        .foregroundStyle(.quaternary)
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date, format: .dateTime.year())
                        }
                    }
                }
            } else {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    AxisGridLine()
                        .foregroundStyle(.quaternary)
                    AxisTick()
                        .foregroundStyle(.quaternary)
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            xAxisLabel(for: date)
                        }
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) {
                AxisGridLine()
                    .foregroundStyle(.quaternary)
                AxisValueLabel()
            }
        }
        .chartPlotStyle { plotArea in
            plotArea
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(accentColor.opacity(0.05))
                )
        }
    }

    private var domain: ClosedRange<Date>? {
        guard let firstDate = points.first?.date, let lastDate = points.last?.date else {
            return nil
        }

        return firstDate...lastDate
    }

    private var latestPoint: ClinicalTrendChartPoint? {
        points.last
    }

    @ViewBuilder
    private func xAxisLabel(for date: Date) -> some View {
        switch axisLabelStyle {
        case .monthDay:
            Text(date, format: .dateTime.month(.abbreviated).day())
        case .month:
            Text(date, format: .dateTime.month(.abbreviated))
        case .year:
            Text(date, format: .dateTime.year())
        }
    }
}

public struct ClinicalMetricSparklineChart: View {
    private let points: [ClinicalTrendChartPoint]
    private let tintColor: Color

    public init(points: [ClinicalTrendChartPoint], tintColor: Color) {
        self.points = points.sorted { $0.date < $1.date }
        self.tintColor = tintColor
    }

    public var body: some View {
        Chart {
            ForEach(points.suffix(6)) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .foregroundStyle(tintColor.opacity(0.7))
            }

            if let latestPoint = points.last {
                PointMark(
                    x: .value("Date", latestPoint.date),
                    y: .value("Value", latestPoint.value)
                )
                .symbolSize(40)
                .foregroundStyle(tintColor)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .chartPlotStyle { plotArea in
            plotArea
                .background(.clear)
        }
    }
}
