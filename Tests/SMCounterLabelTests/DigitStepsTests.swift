import XCTest
@testable import SMCounterLabel

final class DigitStepsTests: XCTestCase {

    // MARK: incrementSteps

    func test_increment_has_minimum_6_steps() {
        // 3→4 is only 1 natural step; must be padded to at least 6
        XCTAssertGreaterThanOrEqual(incrementSteps(from: 3, to: 4).count, 6)
    }

    func test_increment_ends_on_target_digit() {
        XCTAssertEqual(incrementSteps(from: 3, to: 7).last, 7)
    }

    func test_increment_wraps_through_0_when_needed() {
        let steps = incrementSteps(from: 8, to: 2)
        XCTAssertTrue(steps.contains(9))
        XCTAssertTrue(steps.contains(0))
    }

    func test_increment_all_values_in_0_to_9_range() {
        XCTAssertTrue(incrementSteps(from: 0, to: 5).allSatisfy { $0 >= 0 && $0 <= 9 })
    }

    // MARK: decrementSteps

    func test_decrement_has_minimum_6_steps() {
        XCTAssertGreaterThanOrEqual(decrementSteps(from: 4, to: 3).count, 6)
    }

    func test_decrement_ends_on_target_digit() {
        XCTAssertEqual(decrementSteps(from: 7, to: 3).last, 3)
    }

    func test_decrement_wraps_through_0_when_needed() {
        let steps = decrementSteps(from: 2, to: 8)
        XCTAssertTrue(steps.contains(1))
        XCTAssertTrue(steps.contains(0))
        XCTAssertTrue(steps.contains(9))
    }

    func test_decrement_all_values_in_0_to_9_range() {
        XCTAssertTrue(decrementSteps(from: 5, to: 0).allSatisfy { $0 >= 0 && $0 <= 9 })
    }
}
