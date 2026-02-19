import UIKit
import SwiftUI
import SMCounterLabel

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let hosting = UIHostingController(rootView: DemoView())
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        hosting.didMove(toParent: self)
    }
}

private struct DemoView: View {
    @State private var amount: Double = 1234.56

    var body: some View {
        VStack(spacing: 40) {
            CounterLabel(value: amount, format: .fancy)
                .font(.system(size: 50, design: .monospaced))
                .foregroundStyle(.primary)
            Button("Random") {
                amount = Double.random(in: 1...9999)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
