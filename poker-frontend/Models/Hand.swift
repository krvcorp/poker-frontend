enum Hand {
    case none
    case player1
    case player2
    case table
    
    case hero
    case flop
    case turn
    case river

    var isNotNone: Bool {
        get {
            self != .none
        }
        set {
            if !newValue {
                self = .none
            }
        }
    }
    }
