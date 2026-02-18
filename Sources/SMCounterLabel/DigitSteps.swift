/// Single-digit (0–9) values to display when spinning a digit upward from `start` to `end`.
/// Adds at least 10 extra steps so single-step transitions don't look boring.
func incrementSteps(from start: Int, to end: Int) -> [Int] {
    let startVal = start + 1
    var endVal = end + 10
    if (endVal - startVal) < 6 {
        endVal += 10
    }
    return (startVal...endVal).map { $0 % 10 }
}

/// Single-digit (0–9) values to display when spinning a digit downward from `start` to `end`.
func decrementSteps(from start: Int, to end: Int) -> [Int] {
    var startVal = (start - 1) + 10
    if (startVal - end) < 6 {
        startVal += 10
    }
    var steps: [Int] = []
    var val = startVal
    while val >= end {
        steps.append(val % 10)
        val -= 1
    }
    return steps
}
