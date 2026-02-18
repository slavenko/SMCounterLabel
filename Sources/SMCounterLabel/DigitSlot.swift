import SwiftUI

enum AnimationDirection {
    case increment, decrement

    var insertionEdge: Edge { self == .increment ? .top : .bottom }
    var removalEdge: Edge   { self == .increment ? .bottom : .top }
}

@Observable
final class DigitSlot: Identifiable {
    let id = UUID()
    let kind: CharacterSlot
    var displayChar: String
    var slotVersion: UUID = UUID()
    var direction: AnimationDirection = .increment
    /// True when this slot is part of the decimal portion in `.fancy` format.
    var isFancySmall: Bool = false

    init(slot: CharacterSlot) {
        self.kind = slot
        self.displayChar = String(slot.character)
    }

    @MainActor
    func animate(to targetChar: String, direction: AnimationDirection, totalDuration: Double) async {
        guard let startDigit = Int(displayChar), let endDigit = Int(targetChar) else { return }
        self.direction = direction
        let steps = direction == .increment
            ? incrementSteps(from: startDigit, to: endDigit)
            : decrementSteps(from: startDigit, to: endDigit)
        let stepDuration = totalDuration / Double(steps.count)
        for digit in steps {
            try? await Task.sleep(for: .seconds(stepDuration))
            withAnimation(.easeInOut(duration: stepDuration)) {
                displayChar = "\(digit)"
                slotVersion = UUID()
            }
        }
    }
}
