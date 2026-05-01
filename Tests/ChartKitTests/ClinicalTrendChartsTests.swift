import XCTest
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
}
