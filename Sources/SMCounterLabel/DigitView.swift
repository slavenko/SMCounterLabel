import SwiftUI

struct DigitView: View {
    let slot: DigitSlot

    var body: some View {
        Text(slot.displayChar)
            .id(slot.slotVersion)
            .transition(.asymmetric(
                insertion: .move(edge: slot.direction.insertionEdge),
                removal:   .move(edge: slot.direction.removalEdge)
            ))
    }
}
