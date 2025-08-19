//
//  PickMeFoodsUITests.swift
//  PickMeFoodsUITests
//
//  Created by Bishanm on 2025-08-11.
//

import XCTest

final class OutletPOCUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        app = XCUIApplication()
        app.launch()

        // Wait for the screen to exist
        XCTAssertTrue(app.scrollViews["outlet_scroll"].waitForExistence(timeout: 5), "Outlet scroll not found")
        // Wait for a chip (if TagBar is initially visible it’ll be hittable; otherwise it may not)
        _ = app.buttons["tag_Lunch"].waitForExistence(timeout: 2)
    }

    func test_TagBarShowsAndHides() {
        let scroll = app.scrollViews["outlet_scroll"].firstMatch
        // Scroll down until TagBar appears
        for _ in 0..<6 { scroll.swipeUp() }
        XCTAssertTrue(app.buttons["tag_Lunch"].exists, "TagBar didn’t appear after swipes")

        // Scroll up to hide it
        for _ in 0..<6 { scroll.swipeDown() }
        // Give a moment for hysteresis/no-anim flip
        sleep(1)
        XCTAssertFalse(app.buttons["tag_Lunch"].isHittable, "TagBar still hittable after scrolling up")
    }

    func test_TagTapScrollsToSection() {
        // Make sure TagBar is visible
        let scroll = app.scrollViews["outlet_scroll"].firstMatch
        for _ in 0..<6 { scroll.swipeUp() }

        let dinnerChip = app.buttons["tag_Dinner"]
        XCTAssertTrue(dinnerChip.waitForExistence(timeout: 2), "Dinner chip missing")
        if dinnerChip.isHittable { dinnerChip.tap() }

        // Rough assertion: “Dinner” header is visible/pinned
        let dinnerHeader = app.staticTexts
            .containing(NSPredicate(format: "label BEGINSWITH %@", "Dinner"))
            .firstMatch
        XCTAssertTrue(dinnerHeader.waitForExistence(timeout: 2), "Dinner header not found")
        XCTAssertTrue(dinnerHeader.isHittable, "Dinner header not hittable at top")
    }

    func test_PerfScroll() {
        let scroll = app.scrollViews["outlet_scroll"].firstMatch
        measure(metrics: [XCTClockMetric(), XCTCPUMetric(), XCTMemoryMetric()]) {
            for _ in 0..<30 { scroll.swipeUp() }
            for _ in 0..<30 { scroll.swipeDown() }
        }
    }
    
    func test_MonkeyTapAndFling() {
        let scroll = app.scrollViews["outlet_scroll"].firstMatch
        let tags = ["Lunch","Dinner","Promotions","Desserts"]

        // Ensure TagBar is visible first
        scroll.fastSwipeUp(times: 5)

        for i in 0..<120 {
            // 50%: fling up/down
            if i % 2 == 0 {
                scroll.flingUp(app: app)
            } else {
                scroll.flingDown(app: app)
            }

            // 50%: tap a random chip if hittable
            if let t = tags.randomElement() {
                let chip = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tag_\(t)")).firstMatch
                if chip.exists && chip.isHittable { chip.tap() }
            }
        }
    }

    func test_ThresholdJitter_NoFlicker() {
        let scroll = app.scrollViews["outlet_scroll"].firstMatch

        // Scroll until TagBar appears (beyond threshold)
        scroll.fastSwipeUp(times: 4)

        // Now jitter near the boundary with tiny drags
        for _ in 0..<40 {
            let mid = scroll.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            mid.press(forDuration: 0.01, thenDragTo: scroll.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.48)))
            mid.press(forDuration: 0.01, thenDragTo: scroll.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.52)))
        }

        // Expect TagBar still visible (no flapping back to hidden)
        let lunch = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "tag_Lunch")).firstMatch
        XCTAssertTrue(lunch.exists && lunch.isHittable, "TagBar flickered off near threshold")
    }

    func test_TagBarHorizontalScrollAndTapLast() {
        let scroll = app.scrollViews["outlet_scroll"].firstMatch
        scroll.fastSwipeUp(times: 5) // reveal TagBar

        // The TagBar's own horizontal scroll view (first scrollView might be vertical)
        let horizontalBars = app.scrollViews.allElementsBoundByIndex.filter { $0 != scroll }
        let tagBarScroll = horizontalBars.first ?? app.scrollViews.element(boundBy: 1)

        // Swipe left a bunch to bring the last chip into view and tap it repeatedly
        for _ in 0..<6 { tagBarScroll.swipeLeft() }
        let last = app.buttons.containing(NSPredicate(format: "identifier BEGINSWITH %@", "tag_")).allElementsBoundByIndex.last
        if let last, last.exists { for _ in 0..<10 { if last.isHittable { last.tap() } } }
    }

}

extension XCUIElement {
    func fastSwipeUp(times: Int)   { (0..<times).forEach { _ in swipeUp() } }
    func fastSwipeDown(times: Int) { (0..<times).forEach { _ in swipeDown() } }

    // A “fling” uses a short press+drag for a more violent scroll than swipeUp()
    func flingUp(app: XCUIApplication) {
        let start = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let end   = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        start.press(forDuration: 0.01, thenDragTo: end)
    }
    func flingDown(app: XCUIApplication) {
        let start = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        let end   = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        start.press(forDuration: 0.01, thenDragTo: end)
    }
}
