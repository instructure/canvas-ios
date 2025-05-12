import XCTest
@testable import Teacher

class SpeedGraderLandscapeSplitLayoutViewModelTests: XCTestCase {
    var testee: SpeedGraderLandscapeSplitLayoutViewModel!

    override func setUp() {
        super.setUp()
        testee = SpeedGraderLandscapeSplitLayoutViewModel()
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    func test_tappingDragIcon_togglesBetweenFullScreen_andCustomState() {
        let screenWidth: CGFloat = 1200
        testee.updateScreenWidth(screenWidth)

        // WHEN - Drag to custom size
        testee.didUpdateDragGesturePosition(horizontalTranslation: -100)
        testee.didEndDragGesture()

        // THEN
        XCTAssertEqual(testee.leftColumnWidth, (2 * screenWidth) / 3 - 100)
        XCTAssertEqual(testee.rightColumnWidth, screenWidth / 3 + 100)

        // WHEN
        testee.didTapDragIcon()

        // THEN
        XCTAssertEqual(testee.leftColumnWidth, screenWidth)
        XCTAssertEqual(testee.rightColumnWidth, screenWidth / 3)
        XCTAssertEqual(testee.isRightColumnHidden, true)
        XCTAssertEqual(testee.dragIconA11yLabel, "Show drawer menu")
        XCTAssertEqual(testee.dragIconRotation, .degrees(-180))

        // WHEN
        testee.didTapDragIcon()

        // THEN
        XCTAssertEqual(testee.leftColumnWidth, (2 * screenWidth) / 3 - 100)
        XCTAssertEqual(testee.rightColumnWidth, screenWidth / 3 + 100)
        XCTAssertEqual(testee.isRightColumnHidden, false)
        XCTAssertEqual(testee.dragIconA11yLabel, "Hide drawer menu")
        XCTAssertEqual(testee.dragIconRotation, .degrees(0))
    }

    func test_dragToNearScreenEdge_snapsToFullScreen() {
        let screenWidth: CGFloat = 1200
        testee.updateScreenWidth(screenWidth)

        // WHEN
        testee.didUpdateDragGesturePosition(horizontalTranslation: 300)

        // THEN
        XCTAssertEqual(testee.leftColumnWidth, 1100)
        XCTAssertEqual(testee.rightColumnWidth, screenWidth / 3)

        // WHEN
        testee.didEndDragGesture()

        // THEN
        XCTAssertEqual(testee.leftColumnWidth, screenWidth)
        XCTAssertEqual(testee.rightColumnWidth, screenWidth / 3)
    }

    func test_dragToLargerThanMaximumSize_snapsToMaximumSize() {
        let screenWidth: CGFloat = 1200
        testee.updateScreenWidth(screenWidth)

        // WHEN
        testee.didUpdateDragGesturePosition(horizontalTranslation: 100)

        // THEN
        XCTAssertEqual(testee.leftColumnWidth, 900)
        XCTAssertEqual(testee.rightColumnWidth, screenWidth / 3)

        // WHEN
        testee.didEndDragGesture()

        // THEN
        XCTAssertEqual(testee.leftColumnWidth, (2 * screenWidth) / 3)
        XCTAssertEqual(testee.rightColumnWidth, screenWidth / 3)
    }

    func test_dragToSmallerThanMinimumSize_snapsToMinimumSize() {
        let screenWidth: CGFloat = 1200
        testee.updateScreenWidth(screenWidth)

        // WHEN
        testee.didUpdateDragGesturePosition(horizontalTranslation: -700)
        testee.didEndDragGesture()

        // THEN
        XCTAssertEqual(testee.leftColumnWidth, screenWidth / 3)
        XCTAssertEqual(testee.rightColumnWidth, (2 * screenWidth) / 3)
    }
}
