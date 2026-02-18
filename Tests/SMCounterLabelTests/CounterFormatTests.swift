import XCTest
@testable import SMCounterLabel

final class CounterFormatTests: XCTestCase {
    let en = Locale(identifier: "en_US")

    func test_decimal_formats_with_two_decimal_places_and_grouping() {
        XCTAssertEqual(formatNumber(1234.56, format: .decimal, locale: en), "1,234.56")
    }

    func test_decimal_rounds_to_two_decimal_places() {
        XCTAssertEqual(formatNumber(1234.567, format: .decimal, locale: en), "1,234.57")
    }

    func test_integer_strips_decimals_and_grouping() {
        XCTAssertEqual(formatNumber(1234.56, format: .integer, locale: en), "1235")
    }

    func test_fancy_produces_same_string_as_decimal() {
        XCTAssertEqual(
            formatNumber(1234.56, format: .fancy, locale: en),
            formatNumber(1234.56, format: .decimal, locale: en)
        )
    }

    func test_zero() {
        XCTAssertEqual(formatNumber(0, format: .decimal, locale: en), "0.00")
    }
}
