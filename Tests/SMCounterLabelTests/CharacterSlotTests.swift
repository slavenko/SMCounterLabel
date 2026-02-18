import XCTest
@testable import SMCounterLabel

final class CharacterSlotTests: XCTestCase {

    func test_digit_characters_become_digit_slots() {
        XCTAssertEqual(splitIntoSlots("123"), [.digit("1"), .digit("2"), .digit("3")])
    }

    func test_comma_becomes_separator() {
        let slots = splitIntoSlots("1,234")
        XCTAssertEqual(slots[1], .separator(","))
    }

    func test_period_becomes_separator() {
        let slots = splitIntoSlots("1.56")
        XCTAssertEqual(slots[1], .separator("."))
    }

    func test_mixed_string_preserves_order() {
        let slots = splitIntoSlots("1,2")
        XCTAssertEqual(slots, [.digit("1"), .separator(","), .digit("2")])
    }

    func test_empty_string_returns_empty_array() {
        XCTAssertEqual(splitIntoSlots(""), [])
    }
}
