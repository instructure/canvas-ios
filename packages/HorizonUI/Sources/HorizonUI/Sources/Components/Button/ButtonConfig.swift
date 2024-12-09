import SwiftUI

enum ButtonSize {
    case regular
    case small
    
    var height: CGFloat {
        switch self {
        case .regular: return 44
        case .small: return 40
        }
    }
    
    var cornerRadius: CGFloat {
        return height / 2
    }
}

struct ButtonColors {
    static let darkText = Color(red: 39/255, green: 53/255, blue: 64/255)
    static let white = Color.white
    
    struct AI {
        static let gradientTop = Color(red: 9/255, green: 80/255, blue: 140/255)
        static let gradientBottom = Color(red: 2/255, green: 103/255, blue: 45/255)
    }
    
    static let blue = Color(red: 43/255, green: 122/255, blue: 188/255)
    static let beige = Color(red: 251/255, green: 245/255, blue: 237/255)
}

protocol ThemedButtonStyle: ButtonStyle {
    var isSmall: Bool { get }
    var size: ButtonSize { get }
}

extension ThemedButtonStyle {
    var size: ButtonSize {
        isSmall ? .small : .regular
    }
    
    func baseButtonStyle<V: View>(_ content: V, isPressed: Bool, isEnabled: Bool) -> some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: size.height)
    }
}