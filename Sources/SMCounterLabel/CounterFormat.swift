import Foundation

public enum CounterFormat {
    case decimal    // grouping separator + 2 decimal places
    case integer    // no decimals, no grouping
    case fancy      // same string as decimal; decimal portion renders at half font size
}

func formatNumber(_ value: Double, format: CounterFormat, locale: Locale = .current) -> String {
    let formatter = NumberFormatter()
    formatter.locale = locale
    formatter.usesGroupingSeparator = true
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2

    if format == .integer {
        formatter.numberStyle = .none
        formatter.usesGroupingSeparator = false
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
    }

    return formatter.string(from: NSNumber(value: value)) ?? "0"
}
