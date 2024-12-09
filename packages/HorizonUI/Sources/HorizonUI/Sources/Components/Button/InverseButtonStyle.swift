import SwiftUI

struct InverseButtonStyle: ThemedButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    let isSmall: Bool
    
    init(isSmall: Bool = false) {
        self.isSmall = isSmall
    }
    
    func makeBody(configuration: Configuration) -> some View {
        baseButtonStyle(configuration.label, isPressed: configuration.isPressed, isEnabled: isEnabled)
            .background(ButtonColors.white)
            .foregroundStyle(ButtonColors.darkText)
            .cornerRadius(size.cornerRadius)
            .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1.0) : 0.5)
    }
}

extension ButtonStyle where Self == InverseButtonStyle {
    static var inverse: InverseButtonStyle {
        InverseButtonStyle()
    }
    
    static var inverseSmall: InverseButtonStyle {
        InverseButtonStyle(isSmall: true)
    }
}