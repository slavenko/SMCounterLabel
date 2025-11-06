import SwiftUI
import UIKit
import SMCounterLabel

struct CounterDemoView: View {
    private enum FormatOption: String, CaseIterable, Identifiable {
        case decimal
        case integer
        case fancy

        var id: String { rawValue }

        var title: String {
            rawValue.capitalized
        }

        var labelType: SMLabelFormatType {
            switch self {
            case .decimal: return .decimal
            case .integer: return .integer
            case .fancy: return .fancy
            }
        }

        var formatter: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.usesGroupingSeparator = true
            switch self {
            case .integer:
                formatter.numberStyle = .none
                formatter.minimumFractionDigits = 0
                formatter.maximumFractionDigits = 0
            case .decimal, .fancy:
                formatter.numberStyle = .decimal
                formatter.minimumFractionDigits = 2
                formatter.maximumFractionDigits = 2
            }
            return formatter
        }
    }

    @State private var targetValue: Double = 1234.56
    @State private var animationDuration: Double = 0.6
    @State private var animationDelay: Double = 0.2
    @State private var durationIncrement: Double = 0
    @State private var format: FormatOption = .decimal

    private let labelFont = UIFont.monospacedDigitSystemFont(ofSize: 54, weight: .semibold)
    private let labelColor = UIColor.darkGray

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    CounterLabelRepresentable(
                        value: $targetValue,
                        formatType: format.labelType,
                        duration: animationDuration,
                        delay: animationDelay,
                        durationIncrement: durationIncrement,
                        font: labelFont,
                        foregroundColor: labelColor
                    )
                    .frame(height: labelFont.lineHeight * 1.3)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)

                    Text(formattedValue)
                        .font(.system(size: 32, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color(uiColor: labelColor).opacity(0.8))
                        .padding(.horizontal)

                    controls
                }
                .padding(.vertical, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("SMCounterLabel")
            .toolbar { toolbarContent }
        }
        .onChange(of: format) { newValue in
            if newValue == .integer {
                targetValue = round(targetValue)
            }
        }
    }

    private var controls: some View {
        VStack(spacing: 24) {
            formatPicker
            slider(
                title: "Character duration",
                value: $animationDuration,
                range: 0.2...1.5,
                step: 0.05,
                formatter: numberFormatter(suffix: "s")
            )
            slider(
                title: "Character delay",
                value: $animationDelay,
                range: 0.0...0.8,
                step: 0.05,
                formatter: numberFormatter(suffix: "s")
            )
            slider(
                title: "Duration increment",
                value: $durationIncrement,
                range: 0.0...0.6,
                step: 0.05,
                formatter: numberFormatter(suffix: "s")
            )
        }
        .padding(.horizontal)
    }

    private var formatPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Format")
                .font(.headline)
            Picker("Format", selection: $format) {
                ForEach(FormatOption.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private func slider(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        formatter: NumberFormatter
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(title): \(formatter.string(from: NSNumber(value: value.wrappedValue)) ?? "-")")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Slider(value: value, in: range, step: step)
        }
    }

    private func numberFormatter(suffix: String) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.positiveSuffix = suffix
        formatter.negativeSuffix = suffix
        return formatter
    }

    private var formattedValue: String {
        format.formatter.string(from: NSNumber(value: targetValue)) ?? ""
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if format == .integer {
                        targetValue = Double(Int.random(in: 1...9999))
                    } else {
                        targetValue = Double.random(in: 1...9999)
                    }
                }
            } label: {
                Label("Random value", systemImage: "shuffle")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

private struct CounterLabelRepresentable: UIViewRepresentable {
    @Binding var value: Double

    var formatType: SMLabelFormatType
    var duration: Double
    var delay: Double
    var durationIncrement: Double
    var font: UIFont
    var foregroundColor: UIColor
    var textAlignment: NSTextAlignment = .center

    func makeUIView(context: Context) -> SMCounterLabel {
        let label = SMCounterLabel()
        configure(label)
        label.setValue(value)
        return label
    }

    func updateUIView(_ uiView: SMCounterLabel, context: Context) {
        configure(uiView)
        uiView.setValue(value)
    }

    private func configure(_ label: SMCounterLabel) {
        label.font = font
        label.color = foregroundColor
        label.formatType = formatType
        label.duration = duration
        label.delay = delay
        label.durationIncrement = durationIncrement
        label.textAlignment = textAlignment
    }
}

#Preview {
    CounterDemoView()
}
