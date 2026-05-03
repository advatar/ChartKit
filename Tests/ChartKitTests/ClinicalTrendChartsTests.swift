import XCTest
import SwiftUI
@testable import ChartKit

final class ClinicalTrendChartsTests: XCTestCase {
    func testClinicalTrendPointRetainsRenderableValues() {
        let date = Date(timeIntervalSinceReferenceDate: 42)

        let point = ClinicalTrendChartPoint(
            id: "hemoglobin-1",
            date: date,
            value: 14.2,
            renderedValue: "14.2 g/dL"
        )

        XCTAssertEqual(point.id, "hemoglobin-1")
        XCTAssertEqual(point.date, date)
        XCTAssertEqual(point.value, 14.2)
        XCTAssertEqual(point.renderedValue, "14.2 g/dL")
    }

    func testClinicalTrendReferenceBandRetainsBounds() {
        let band = ClinicalTrendReferenceBand(low: 4.0, high: 10.0)

        XCTAssertEqual(band.low, 4.0)
        XCTAssertEqual(band.high, 10.0)
    }

    @available(iOS 17.0, macOS 14.0, *)
    func testClinicalMetricTrendChartAcceptsHistoricalPointsAndReferenceBand() {
        let start = Date(timeIntervalSinceReferenceDate: 1_000)
        let points = [
            ClinicalTrendChartPoint(id: "glucose-1", date: start, value: 4.8, renderedValue: "4.8 mmol/L"),
            ClinicalTrendChartPoint(id: "glucose-2", date: start.addingTimeInterval(86_400), value: 5.2, renderedValue: "5.2 mmol/L"),
            ClinicalTrendChartPoint(id: "glucose-3", date: start.addingTimeInterval(172_800), value: 5.5, renderedValue: "5.5 mmol/L")
        ]
        let band = ClinicalTrendReferenceBand(low: 3.9, high: 5.5)

        let chart = ClinicalMetricTrendChart(
            points: points,
            selectedPoint: points.last,
            referenceBand: band,
            visibleDomainLength: 30 * 24 * 60 * 60,
            usesYearAxisLabels: false,
            axisLabelStyle: .monthDay,
            accentColor: .green,
            selectedDate: Binding<Date?>.constant(nil),
            scrollPosition: Binding<Date>.constant(points[1].date)
        )

        XCTAssertEqual(points.count, 3)
        XCTAssertEqual(band, ClinicalTrendReferenceBand(low: 3.9, high: 5.5))
        _ = chart
    }
}
