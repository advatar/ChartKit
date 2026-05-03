//
// Copyright © 2026 ChartKit.
// Open Source - MIT License

import Charts
import SwiftUI

public struct HealthMetricChartPoint: Identifiable, Hashable {
    public let id: Date
    public let date: Date
    public let value: Double

    public init(id: Date, date: Date, value: Double) {
        self.id = id
        self.date = date
        self.value = value
    }
}

public enum HealthMetricChartStyle: Hashable {
    case line
    case bar
}

public struct HealthMetricSparklineChart: View {
    private let points: [HealthMetricChartPoint]
    private let style: HealthMetricChartStyle
    private let tintColor: Color

    public init(points: [HealthMetricChartPoint], style: HealthMetricChartStyle, tintColor: Color) {
        self.points = points.sorted { $0.date < $1.date }
        self.style = style
        self.tintColor = tintColor
    }

    public var body: some View {
        Chart {
            switch style {
            case .line:
                ForEach(points) { point in
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(tintColor.opacity(0.12))

                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(tintColor)
                }
            case .bar:
                ForEach(points) { point in
                    BarMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.value)
                    )
                    .clipShape(Capsule())
                    .foregroundStyle(tintColor.gradient)
                }
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .chartPlotStyle { plot in
            plot.background(.clear)
        }
    }
}

public struct HealthMetricChart: View {
    private let points: [HealthMetricChartPoint]
    private let style: HealthMetricChartStyle
    private let tintColor: Color
    private let desiredXAxisMarkCount: Int
    private let dateFormat: Date.FormatStyle

    public init(
        points: [HealthMetricChartPoint],
        style: HealthMetricChartStyle,
        tintColor: Color,
        desiredXAxisMarkCount: Int,
        dateFormat: Date.FormatStyle
    ) {
        self.points = points.sorted { $0.date < $1.date }
        self.style = style
        self.tintColor = tintColor
        self.desiredXAxisMarkCount = desiredXAxisMarkCount
        self.dateFormat = dateFormat
    }

    public var body: some View {
        Chart {
            switch style {
            case .line:
                ForEach(points) { point in
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(tintColor.opacity(0.15))

                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(tintColor)

                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.value)
                    )
                    .symbolSize(16)
                    .foregroundStyle(tintColor)
                }
            case .bar:
                ForEach(points) { point in
                    BarMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.value)
                    )
                    .clipShape(Capsule())
                    .foregroundStyle(tintColor.gradient)
                }
            }
        }
        .chartLegend(.hidden)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: desiredXAxisMarkCount)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.6))
                    .foregroundStyle(.quaternary)
                AxisTick()
                    .foregroundStyle(.secondary)
                AxisValueLabel(format: dateFormat)
                    .foregroundStyle(.secondary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.6))
                    .foregroundStyle(.quaternary)
                AxisValueLabel()
                    .foregroundStyle(.secondary)
            }
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color.primary.opacity(0.025))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}
