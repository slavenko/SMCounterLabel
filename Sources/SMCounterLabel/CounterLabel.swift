import SwiftUI

public struct CounterLabel: View {
    public var value: Double
    public var format: CounterFormat = .decimal
    public var duration: Double = 0.6
    public var delay: Double = 0.2
    public var durationIncrement: Double = 0.0

    @State private var slots: [DigitSlot] = []
    @State private var animationTask: Task<Void, Never>?

    public init(
        value: Double,
        format: CounterFormat = .decimal,
        duration: Double = 0.6,
        delay: Double = 0.2,
        durationIncrement: Double = 0.0
    ) {
        self.value = value
        self.format = format
        self.duration = duration
        self.delay = delay
        self.durationIncrement = durationIncrement
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(slots) { slot in
                switch slot.kind {
                case .digit:
                    DigitView(slot: slot)
                        .clipped()
                        .font(slot.isFancySmall ? .caption : nil)
                case .separator(let char):
                    Text(String(char))
                        .font(slot.isFancySmall ? .caption : nil)
                }
            }
        }
        .clipped()
        .onAppear { buildSlots(for: value) }
        .onChange(of: value) { oldVal, newVal in
            animationTask?.cancel()
            animationTask = Task { await animate(from: oldVal, to: newVal) }
        }
    }

    // MARK: - Private

    private func buildSlots(for value: Double) {
        let formatted = formatNumber(value, format: format)
        let rawSlots = splitIntoSlots(formatted)
        let decimalIndex = decimalSeparatorIndex(in: formatted)
        slots = rawSlots.enumerated().map { index, slot in
            let ds = DigitSlot(slot: slot)
            ds.isFancySmall = format == .fancy && decimalIndex != nil && index >= decimalIndex!
            return ds
        }
    }

    @MainActor
    private func animate(from oldValue: Double, to newValue: Double) async {
        let oldFormatted = formatNumber(oldValue, format: format)
        let newFormatted = formatNumber(newValue, format: format)
        let direction: AnimationDirection = newValue >= oldValue ? .increment : .decrement

        // Rebuild slots completely if the string length changed (e.g. 999 → 1000)
        if oldFormatted.count != newFormatted.count {
            buildSlots(for: newValue)
            return
        }

        let newRawSlots = splitIntoSlots(newFormatted)
        var slotDelay = 0.0
        var slotDuration = duration

        for (index, newSlot) in newRawSlots.enumerated() {
            guard index < slots.count else { break }
            guard case .digit(let newChar) = newSlot,
                  case .digit(let oldChar) = slots[index].kind,
                  newChar != oldChar else { continue }

            let slot = slots[index]
            let targetChar = String(newChar)
            let capturedDelay = slotDelay
            let capturedDuration = slotDuration

            Task {
                try? await Task.sleep(for: .seconds(capturedDelay))
                await slot.animate(to: targetChar, direction: direction, totalDuration: capturedDuration)
            }

            slotDelay += delay
            slotDuration += durationIncrement
        }
    }

    /// Returns the index of the decimal separator character in the formatted string, or nil.
    private func decimalSeparatorIndex(in string: String) -> Int? {
        let decimalSep = Locale.current.decimalSeparator ?? "."
        guard let range = string.range(of: decimalSep) else { return nil }
        return string.distance(from: string.startIndex, to: range.lowerBound)
    }
}
