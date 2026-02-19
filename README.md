# SMCounterLabel

[![License](https://img.shields.io/github/license/slavenko/SMCounterLabel.svg?style=flat)](https://github.com/slavenko/SMCounterLabel/blob/master/LICENSE)
[![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-blue.svg?style=flat)](https://developer.apple.com/swift/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg?style=flat)](https://swift.org)

A native SwiftUI view that animates numeric value changes with a slot-machine effect — each digit spins independently.

![Screenshot](animation.gif)

## Requirements

- iOS 17+ / macOS 14+
- Swift 5.9+
- Xcode 15+

## Installation

### Swift Package Manager

In Xcode: **File → Add Package Dependencies…** and enter the repo URL:

```
https://github.com/slavenko/SMCounterLabel.git
```

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/slavenko/SMCounterLabel.git", from: "1.0.0")
]
```

## Usage

```swift
import SwiftUI
import SMCounterLabel

struct ContentView: View {
    @State private var amount: Double = 1234.56

    var body: some View {
        CounterLabel(value: amount, format: .fancy)
            .font(.system(size: 50, design: .monospaced))
    }
}
```

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | `Double` | — | The numeric value to display |
| `format` | `CounterFormat` | `.decimal` | Number format style |
| `duration` | `Double` | `0.6` | Animation duration per digit (seconds) |
| `delay` | `Double` | `0.2` | Delay between each digit animating |
| `durationIncrement` | `Double` | `0.0` | Extra duration added per digit (slows toward end) |

### Format styles

| Value | Output | Notes |
|-------|--------|-------|
| `.decimal` | `1,234.56` | Grouping separator + 2 decimal places |
| `.integer` | `1235` | Rounded, no decimals |
| `.fancy` | `1,234.56` | Same as decimal; decimal portion renders smaller |

## Author

Slavenko Miljic, slavenko.miljic@gmail.com

## License

SMCounterLabel is available under the MIT license. See the LICENSE file for more info.
