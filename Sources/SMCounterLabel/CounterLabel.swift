import SwiftUI

public struct CounterLabel: View {
    public var value: Double
    public var format: CounterFormat = .decimal
    public var fontSize: CGFloat = 17
    public var decimalScale: CGFloat = 0.5
    public var duration: Double = 0.6
    public var delay: Double = 0.2
    public var durationIncrement: Double = 0.0

    @State private var slots: [DigitSlot] = []
    @State private var animationTask: Task<Void, Never>?
    @State private var currentDirection: AnimationDirection = .increment

    public init(
        value: Double,
        format: CounterFormat = .decimal,
        fontSize: CGFloat = 17,
        decimalScale: CGFloat = 0.5,
        duration: Double = 0.6,
        delay: Double = 0.2,
        durationIncrement: Double = 0.0
    ) {
        self.value = value
        self.format = format
        self.fontSize = fontSize
        self.decimalScale = decimalScale
        self.duration = duration
        self.delay = delay
        self.durationIncrement = durationIncrement
    }

    public var body: some View {
		HStack(alignment: .center, spacing: 0) {
            ForEach(slots) { slot in
                slotView(for: slot)
                    .transition(slotTransition(for: slot))
            }
        }
        .font(.system(size: fontSize, design: .monospaced))
        .clipped()
        .onAppear { buildSlots(for: value) }
        .onChange(of: value) { oldVal, newVal in
            animationTask?.cancel()
            animationTask = Task { await animate(from: oldVal, to: newVal) }
        }
    }

    private func slotTransition(for slot: DigitSlot) -> AnyTransition {
        guard case .digit = slot.kind else { return .identity }
        return .asymmetric(
            insertion: .move(edge: currentDirection.insertionEdge),
            removal:   .move(edge: currentDirection.removalEdge)
        )
    }

    @ViewBuilder
    private func slotView(for slot: DigitSlot) -> some View {
        let smallFont = Font.system(size: fontSize * decimalScale)
        switch slot.kind {
        case .digit:
            if slot.isFancySmall {
                DigitView(slot: slot).clipped().font(smallFont)
            } else {
                DigitView(slot: slot).clipped()
            }
        case .separator(let char):
            if slot.isFancySmall {
                Text(String(char)).font(smallFont)
            } else {
                Text(String(char))
            }
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
        currentDirection = direction

        if oldFormatted.count != newFormatted.count {
            animateLengthChange(newFormatted: newFormatted, direction: direction)
            return
        }

        animateSameLength(newFormatted: newFormatted, direction: direction)
    }

    /// When digit count changes: right-align old and new digit sequences.
    /// Extra leading slots slide out, new leading slots slide in, overlapping slots animate in place.
    private func animateLengthChange(newFormatted: String, direction: AnimationDirection) {
        let existingDigitSlots = slots.filter { guard case .digit = $0.kind else { return false }; return true }
        let newRaw = splitIntoSlots(newFormatted)
        let newDigitRaw = newRaw.filter { guard case .digit = $0 else { return false }; return true }

        let oldDigitCount = existingDigitSlots.count
        let newDigitCount = newDigitRaw.count
        let overlap = min(oldDigitCount, newDigitCount)
        // How many new leading digits have no old counterpart
        let newLeadingCount = newDigitCount - overlap
        // Trailing old digit slots that map to new digits (right-aligned)
        let keptDigitSlots = Array(existingDigitSlots.suffix(overlap))

        // Build the new slot array, reusing kept slot objects for overlapping digits
        let decimalIndex = decimalSeparatorIndex(in: newFormatted)
        var newSlots: [DigitSlot] = []
        var overlapIdx = 0
        var newDigitIdx = 0

        for (i, rawSlot) in newRaw.enumerated() {
            let ds: DigitSlot
            if case .digit = rawSlot {
                if newDigitIdx < newLeadingCount {
                    // Brand-new leading digit — create fresh slot
                    ds = DigitSlot(slot: rawSlot)
                    ds.displayChar = direction == .increment ? "0" : "9"
                } else {
                    // Overlapping digit — reuse existing slot so it animates in place
                    ds = keptDigitSlots[overlapIdx]
                    overlapIdx += 1
                }
                newDigitIdx += 1
            } else {
                ds = DigitSlot(slot: rawSlot)
            }
            ds.isFancySmall = format == .fancy && decimalIndex != nil && i >= decimalIndex!
            newSlots.append(ds)
        }

        // Update slots array: SwiftUI slides removed slots out, new slots in
        withAnimation(.easeInOut(duration: duration)) {
            slots = newSlots
        }

        // Animate every digit to its target value
        let allDigitSlots = newSlots.filter { guard case .digit = $0.kind else { return false }; return true }
        let allTargetChars = newDigitRaw.compactMap { slot -> Character? in
            guard case .digit(let c) = slot else { return nil }; return c
        }

        var slotDelay = 0.0
        var slotDuration = self.duration
        for (slot, targetChar) in zip(allDigitSlots, allTargetChars) {
            let target = String(targetChar)
            guard slot.displayChar != target else { continue }
            let capturedDelay = slotDelay
            let capturedDuration = slotDuration
            Task {
                try? await Task.sleep(for: .seconds(capturedDelay))
                await slot.animate(to: target, direction: direction, totalDuration: capturedDuration)
            }
            slotDelay += delay
            slotDuration += durationIncrement
        }
    }

    /// Same digit count: animate only changed digit slots.
    private func animateSameLength(newFormatted: String, direction: AnimationDirection) {
        let newRawSlots = splitIntoSlots(newFormatted)
        var slotDelay = 0.0
        var slotDuration = duration

        for (index, newSlot) in newRawSlots.enumerated() {
            guard index < slots.count,
                  case .digit(let newChar) = newSlot else { continue }
            let slot = slots[index]
            let targetChar = String(newChar)
            guard slot.displayChar != targetChar else { continue }
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

    /// Returns the character index of the decimal separator in the formatted string, or nil.
    private func decimalSeparatorIndex(in string: String) -> Int? {
        let decimalSep = Locale.current.decimalSeparator ?? "."
        guard let range = string.range(of: decimalSep) else { return nil }
        return string.distance(from: string.startIndex, to: range.lowerBound)
    }
}


#Preview {
    @Previewable @State var amount: Double = 1234.56
	VStack(alignment: .trailing, spacing: 40) {
		CounterLabel(value: amount, format: .fancy, fontSize: 50)
            .frame(maxWidth: .infinity, alignment: .trailing)
        Button("Random") {
            amount = Double.random(in: 1...19999)
        }
        .buttonStyle(.borderedProminent)
    }
	.frame(maxWidth: .infinity, maxHeight: .infinity)
	.padding()
}
