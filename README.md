# SMCounterLabel

A lightweight SwiftUI component that renders animated, odometer-style digits. Each change rolls
through intermediate values so every digit spins independently like a mechanical counter.

## Features

- Pure SwiftUI implementation with no UIKit bridging code
- Rolling animation per digit with configurable font, spacing, animation, and extra spins
- Supports negative numbers and any integer type that conforms to `BinaryInteger`

## Usage

Add the package to your project (Swift Package Manager is supported) and render the counter:

```swift
import SMCounterLabel
import SwiftUI

struct ContentView: View {
    @State private var value = 1995

    var body: some View {
        VStack(spacing: 32) {
            RollingCounterView(value: value, extraSpinCount: 2)
            Stepper("Value: \(value)", value: $value, in: -9999...9999)
        }
        .padding()
    }
}
```

### Customization

`RollingCounterView` exposes a handful of parameters for tuning the look and feel:

- `font`: Apply any `Font` to the digits (default: rounded 48pt)
- `digitSpacing`: Control spacing between columns (default: 4)
- `animation`: Provide a custom `Animation` to tweak the roll dynamics
- `extraSpinCount`: Add extra full rotations on each change (default: 1)

## License

MIT License. See [LICENSE](LICENSE) for details.
