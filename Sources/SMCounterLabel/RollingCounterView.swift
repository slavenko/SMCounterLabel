import SwiftUI

/// A SwiftUI view that animates numeric transitions by rolling each digit independently
/// similar to an odometer or scroll wheel.
public struct RollingCounterView<Value: BinaryInteger>: View {
    /// The value presented by the counter.
    public var value: Value

    /// The font applied to all digits.
    public var font: Font

    /// Horizontal spacing between digits.
    public var digitSpacing: CGFloat

    /// The animation used when digits roll to new values.
    public var animation: Animation

    /// Extra full revolutions performed during every digit change.
    public var extraSpinCount: Int

    @State private var columns: [DigitColumn]
    @State private var previousMagnitude: Int

    /// Creates a rolling counter view.
    /// - Parameters:
    ///   - value: The numeric value to display.
    ///   - font: The font applied to digits. Defaults to a rounded system font.
    ///   - digitSpacing: Spacing between digits. Defaults to 4 points.
    ///   - animation: The animation describing the rolling motion. Defaults to an interactive spring.
    ///   - extraSpinCount: Additional full revolutions performed for each change. Defaults to 1 spin.
    public init(
        value: Value,
        font: Font = .system(size: 48, weight: .medium, design: .rounded),
        digitSpacing: CGFloat = 4,
        animation: Animation = .interactiveSpring(response: 0.35, dampingFraction: 0.78, blendDuration: 0.25),
        extraSpinCount: Int = 1
    ) {
        self.value = value
        self.font = font
        self.digitSpacing = digitSpacing
        self.animation = animation
        self.extraSpinCount = max(extraSpinCount, 0)

        let magnitude = Self.magnitude(of: value)
        _columns = State(initialValue: Self.makeColumns(for: magnitude))
        _previousMagnitude = State(initialValue: magnitude)
    }

    public var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: digitSpacing) {
            if value < 0 {
                Text("-")
                    .font(font)
            }

            ForEach(columns) { column in
                DigitContainer(
                    displayValue: column.displayValue,
                    font: font,
                    animation: animation
                )
            }
        }
        .onAppear {
            synchronizeColumns(with: previousMagnitude)
        }
        .onChange(of: value) { newValue in
            updateColumns(for: Self.magnitude(of: newValue))
        }
    }
}

// MARK: - Internal helpers

private extension RollingCounterView {
    static func magnitude(of value: Value) -> Int {
        Int(abs(value))
    }

    static func makeColumns(for magnitude: Int) -> [DigitColumn] {
        digits(for: magnitude).map { DigitColumn(displayValue: Double($0)) }
    }

    static func digits(for magnitude: Int) -> [Int] {
        let characters = String(magnitude)
        return characters.compactMap { $0.wholeNumberValue }
    }

    func synchronizeColumns(with magnitude: Int) {
        columns = Self.makeColumns(for: magnitude)
        previousMagnitude = magnitude
    }

    func updateColumns(for magnitude: Int) {
        var newDigits = Self.digits(for: magnitude)

        if newDigits.count < columns.count {
            columns.removeFirst(columns.count - newDigits.count)
        } else if newDigits.count > columns.count {
            let missingCount = newDigits.count - columns.count
            let prefix = newDigits.prefix(missingCount).map { DigitColumn(displayValue: Double($0)) }
            columns.insert(contentsOf: prefix, at: 0)
        }

        if newDigits.isEmpty {
            newDigits = [0]
        }

        // Align digits with existing columns (they now have matching counts).
        for index in columns.indices {
            let digit = newDigits[index]
            columns[index].advance(to: digit, extraSpins: extraSpinCount)
        }

        previousMagnitude = magnitude
    }
}

// MARK: - Digit column model

private struct DigitColumn: Identifiable {
    let id = UUID()
    private(set) var displayValue: Double

    private var currentDigit: Int {
        let integer = Int(displayValue)
        let normalized = ((integer % 10) + 10) % 10
        return normalized
    }

    mutating func advance(to newDigit: Int, extraSpins: Int) {
        let safeDigit = ((newDigit % 10) + 10) % 10
        guard safeDigit != currentDigit || extraSpins > 0 else { return }

        var target = displayValue + Double(safeDigit - currentDigit)
        if target <= displayValue {
            target += 10
        }
        target += Double(extraSpins * 10)

        displayValue = target
    }
}

// MARK: - Digit rendering views

private struct DigitContainer: View {
    var displayValue: Double
    var font: Font
    var animation: Animation

    var body: some View {
        ZStack {
            Text("8")
                .font(font)
                .opacity(0)
            RollingDigit(displayValue: displayValue, font: font)
        }
        .fixedSize()
        .animation(animation, value: displayValue)
    }
}

private struct RollingDigit: View, Animatable {
    var displayValue: Double
    var font: Font

    var animatableData: Double {
        get { displayValue }
        set { displayValue = newValue }
    }

    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width

            let base = floor(displayValue)
            let current = Int(base)
            let normalizedCurrent = ((current % 10) + 10) % 10
            let next = (normalizedCurrent + 1) % 10
            let fraction = min(max(displayValue - base, 0), 1)

            VStack(spacing: 0) {
                Text(String(normalizedCurrent))
                    .font(font)
                    .frame(width: width, height: height, alignment: .center)
                Text(String(next))
                    .font(font)
                    .frame(width: width, height: height, alignment: .center)
            }
            .offset(y: -fraction * height)
        }
        .clipped()
    }
}

#if DEBUG
struct RollingCounterView_Previews: PreviewProvider {
    struct Demo: View {
        @State private var value: Int = 1234

        var body: some View {
            VStack(spacing: 24) {
                RollingCounterView(value: value)
                Stepper("Value: \(value)", value: $value, in: -9999...9999)
                    .padding(.horizontal)
            }
            .padding()
        }
    }

    static var previews: some View {
        Demo()
    }
}
#endif
