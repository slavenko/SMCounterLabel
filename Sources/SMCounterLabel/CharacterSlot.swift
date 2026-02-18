enum CharacterSlot: Equatable {
    case digit(Character)
    case separator(Character)

    var character: Character {
        switch self {
        case .digit(let c), .separator(let c): return c
        }
    }
}

func splitIntoSlots(_ string: String) -> [CharacterSlot] {
    string.map { char in
        char.isNumber ? .digit(char) : .separator(char)
    }
}
