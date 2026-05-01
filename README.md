# ChartKit

ChartKit is a Swift Package of reusable SwiftUI chart examples and Apple Health-inspired chart components built on Apple Swift Charts. The repository also includes a small demo app that consumes the package and renders every chart with sample data.

The current package has two purposes:

- Provide a catalog of reusable Swift Charts implementations.
- Provide fixture-backed Apple Health and Clinical Health Record chart families that another app can embed before wiring in HealthKit or FHIR data adapters.

## Requirements

- Xcode 15 or newer
- Swift 5.9 or newer
- iOS 16 or newer
- macOS 13 or newer
- SwiftUI
- Charts

The package does not request HealthKit authorization. Health and Clinical charts currently render from normalized fixture models so the visual components can be inspected and integrated independently of HealthKit permissions.

## Repository Layout

```text
Package.swift
Sources/ChartKit/
  Charts/                 Existing Swift Charts examples
  Data/                   Sample data used by the original chart examples
  HealthCharts/           Apple Health and Clinical Health Record chart models, fixtures, and views
  Model/                  Demo catalog registration
  Utilities/              Shared platform and accessibility helpers
Swift Charts Examples/    Demo app shell
Swift Charts ExamplesTests/
```

The Xcode app target is intentionally thin. It imports `ChartKit` and launches `ChartGalleryView`.

## Using The Package In Another App

### Swift Package Manager

In Xcode:

1. Open your app project.
2. Choose `File > Add Package Dependencies...`.
3. Add this repository URL:

```text
git@github.com:advatar/Swift-Charts-Examples.git
```

4. Select the `ChartKit` package product.
5. Import the package where you want to render charts:

```swift
import ChartKit
```

For a local package during development, add this repository folder as a local package dependency and select the `ChartKit` product.

### Package Manifest Dependency

```swift
// Package.swift
dependencies: [
    .package(url: "git@github.com:advatar/Swift-Charts-Examples.git", branch: "main")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "ChartKit", package: "Swift-Charts-Examples")
        ]
    )
]
```

## Quick Start

Render the complete gallery:

```swift
import ChartKit
import SwiftUI

struct ChartsScreen: View {
    var body: some View {
        ChartGalleryView()
    }
}
```

This is the currently public package entry point. The individual chart examples are still mostly internal to the package while the API is being shaped. For now, consume `ChartGalleryView` directly or use the source as implementation references.

## Demo App

To inspect the charts visually, run the included demo app:

```sh
open "Swift Charts Examples.xcodeproj"
```

Then select the `Swift Charts Examples` scheme and run it.

Command-line build:

```sh
xcodebuild \
  -scheme 'Swift Charts Examples' \
  -project 'Swift Charts Examples.xcodeproj' \
  -destination 'platform=macOS' \
  build \
  CODE_SIGNING_ALLOWED=NO
```

The demo sidebar includes these sample sections:

- `apple`
- `line`
- `bar`
- `area`
- `range`
- `heatMap`
- `point`
- `health`
- `clinical`

## Health Charts

Health chart code lives in `Sources/ChartKit/HealthCharts`.

### Implemented Health Families

- Quantity timeline: cumulative bars for metrics such as Steps.
- Quantity range timeline: min/average/max rendering for metrics such as Heart Rate.
- Classification band chart: Cardio Fitness-style trend with background bands.
- Typical range chart: Vitals-style overnight metric plotted against a normal range.
- Sleep stages chart: hypnogram with Awake, REM, Core, and Deep intervals.
- Cycle Tracking timeline: day-based timeline for period prediction, fertile window, likely ovulation, logged period, and logged info.
- Medication and event timeline: scheduled/taken/skipped/detected/resolved events.
- Workout detail charts: heart rate, pace, and elevation examples.

### Health Data Model

The Health chart components use normalized models rather than direct HealthKit types:

- `HealthQuantityBucket`
- `HealthRangeBand`
- `SleepStageSegment`
- `CycleTrackingDay`
- `HealthEvent`
- `WorkoutMetricPoint`

This keeps rendering independent from HealthKit authorization and query mechanics. A production app should query HealthKit, aggregate or normalize the samples, then feed equivalent values into these chart models.

Typical HealthKit mapping:

- Cumulative quantity samples, such as steps, map to `HealthQuantityBucket.value`.
- Discrete metrics, such as heart rate, can map average/min/max values into `HealthQuantityBucket.value`, `minimum`, and `maximum`.
- Sleep analysis category samples map to `SleepStageSegment`.
- Category samples and app-level state map to `HealthEvent`.
- `HKWorkout` plus associated samples map to `WorkoutMetricPoint` or a future richer workout series model.

## Clinical Health Record Charts

Clinical Health Record support is also in `Sources/ChartKit/HealthCharts`.

Clinical records are not normal `HKQuantitySample` values. HealthKit exposes them as read-only `HKClinicalRecord` samples containing FHIR-backed data. ChartKit models those records separately so clinical observations are not accidentally merged with user-tracked HealthKit samples.

### Implemented Clinical Families

- Clinical lab result trend chart.
- Clinical vital sign trend chart.
- Dedicated blood pressure chart for paired systolic/diastolic observations.
- Clinical timeline for immunizations, medications, conditions, procedures, and allergies.
- Clinical notes and coverage views.

### Clinical Data Model

Current normalized clinical models:

- `ClinicalObservationPoint`
- `ClinicalBloodPressureReading`
- `ClinicalTimelineRecord`

Suggested FHIR mapping:

- FHIR `Observation.valueQuantity` maps to `ClinicalObservationPoint.value` and `unit`.
- FHIR `Observation.referenceRange` maps to future range bands or threshold metadata.
- FHIR `Observation.interpretation` maps to abnormal/high/low visual state.
- Component-based blood pressure observations map systolic and diastolic components into `ClinicalBloodPressureReading`.
- FHIR `Immunization`, `MedicationRequest`/`MedicationStatement`, `Condition`, `Procedure`, `AllergyIntolerance`, `DocumentReference`, and `Coverage` map to timeline/card records.

## Fixture Data

Sample Health and Clinical data is in:

```text
Sources/ChartKit/HealthCharts/HealthChartFixtures.swift
```

The fixtures are intentionally realistic enough to inspect layout and interaction states, but they are not intended to be medically accurate reference datasets.

## Current API Stability

The package is in an early refactor state.

- `ChartGalleryView` is public and intended for demo/gallery embedding.
- Most individual chart components and model types are internal today.
- The Health and Clinical chart views are fixture-backed first-pass implementations.
- Public per-chart APIs should be stabilized once the HealthKit/FHIR adapter layer is designed.

If another app needs to consume an individual chart immediately, promote the specific view and model types to `public` in a narrow follow-up change rather than making the entire package surface public at once.

## Building And Testing

Build the package:

```sh
swift build
```

Build the demo app:

```sh
xcodebuild \
  -scheme 'Swift Charts Examples' \
  -project 'Swift Charts Examples.xcodeproj' \
  -destination 'platform=macOS' \
  build \
  CODE_SIGNING_ALLOWED=NO
```

Build the test bundle:

```sh
xcodebuild \
  -scheme 'Swift Charts Examples' \
  -project 'Swift Charts Examples.xcodeproj' \
  -destination 'platform=macOS' \
  build-for-testing \
  CODE_SIGNING_ALLOWED=NO
```

## Adding A New Chart

1. Add the chart view under `Sources/ChartKit/Charts` or `Sources/ChartKit/HealthCharts`.
2. Add or reuse a normalized fixture/data model.
3. Register the chart in `Sources/ChartKit/Model/ChartType.swift`.
4. Confirm it appears in `ChartGalleryView`.
5. Build with `swift build`.
6. Build the demo app with `xcodebuild`.

For charts intended for app reuse, prefer a small normalized model over taking direct framework types in the view initializer. This keeps the rendering layer testable and lets apps provide data from HealthKit, FHIR, JSON fixtures, or mock data.

## Accessibility

Many of the original charts include accessibility descriptors or mark-level accessibility labels. The Health and Clinical chart implementations need additional pass-by-pass accessibility hardening as the visual designs stabilize.

Expected accessibility behavior:

- Announce selected value, unit, date, and source.
- Summarize visible range and trend.
- Describe threshold bands and abnormal values semantically.
- Represent sleep stage duration totals.
- Preserve clinical source/institution context where available.

## Roadmap

The GitHub issues in this repository track the Health and Clinical chart implementation plan. The main areas are:

- Health quantity and range chart parity.
- Sleep stages parity.
- Cycle, medications, events, and workouts.
- HealthKit data normalization.
- Clinical lab/vital observations.
- Clinical blood pressure.
- Clinical record timelines.
- Screenshot catalog and visual QA against Apple Health references.

## Original Swift Charts Examples

The package still includes the original chart examples as implementation references.

### [Apple](Sources/ChartKit/Charts/AppleCharts)

Electrocardiograms (ECG)

<img src="images/charts/apple/heartBeat.png" width="380">

iPhone Storage

<img src="images/charts/apple/oneDimensionalBar.png" width="380">

Screen Time

<img src="images/charts/apple/screenTime.png" width="380">

### [Line Charts](Sources/ChartKit/Charts/LineCharts)

Line Chart

<img src="images/charts/line/singleLine.png" width="380">

Line Chart with Lollipop

<img src="images/charts/line/singleLineLollipop.png" width="380">

Animating Line

<img src="images/charts/line/animatingLine.png" width="380">

Line with changing gradient

<img src="images/charts/line/gradientLine.png" width="380">

Line Charts

<img src="images/charts/line/multiLine.png" width="380">

Line Point

<img src="images/charts/line/linePoint.png" width="380">

### [Bar Charts](Sources/ChartKit/Charts/BarCharts)

Single Bar

<img src="images/charts/bar/singleBar.png" width="380">

Single Bar with Threshold Rule Mark

<img src="images/charts/bar/singleBarThreshold.png" width="380">

Two Bars

<img src="images/charts/bar/twoBars.png" width="380">

Pyramid

<img src="images/charts/bar/pyramid.png" width="380">

Time Sheet Bar

<img src="images/charts/bar/timeSheetBar.png" width="380">

Sound Bar

<img src="images/charts/bar/soundBar.png" width="380">

Horizontal Scrolling Bar Chart

<img src="images/charts/bar/scrollingBar.png" width="380">

### [Area Charts](Sources/ChartKit/Charts/AreaCharts)

Area Chart

<img src="images/charts/area/areaSimple.png" width="380">

Stacked Area Chart

<img src="images/charts/area/stackedArea.png" width="380">

### [Range Charts](Sources/ChartKit/Charts/RangeCharts)

Range Chart

<img src="images/charts/range/rangeSimple.png" width="380">

Heart Rate Range Chart

<img src="images/charts/range/rangeHeartRate.png" width="380">

Candle Stick Chart

<img src="images/charts/range/candleStick.png" width="380">

### [Heat Maps](Sources/ChartKit/Charts/HeatMap)

Customizable Heat Map

<img src="images/charts/heatMap/customizeableHeatMap.png" width="380">

GitHub Contributions Graph

<img src="images/charts/heatMap/gitContributions.png" width="380">

### [Point Charts](Sources/ChartKit/Charts/PointCharts)

Scatter Chart

<img src="images/charts/point/scatter.png" width="380">

Vector Field

<img src="images/charts/point/vectorField.png" width="380">

## License

Open Source - MIT License. See `LICENSE`.
