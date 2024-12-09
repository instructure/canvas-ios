import SwiftUI

struct BlueButtonStyle: ThemedButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    let isSmall: Bool
    
    init(isSmall: Bool = false) {
        self.isSmall = isSmall
    }
    
    func makeBody(configuration: Configuration) -> some View {
        baseButtonStyle(configuration.label, isPressed: configuration.isPressed, isEnabled: isEnabled)
            .background(ButtonColors.blue)
            .foregroundStyle(ButtonColors.white)
            .cornerRadius(size.cornerRadius)
            .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1.0) : 0.5)
    }
}

extension ButtonStyle where Self == BlueButtonStyle {
    static var blue: BlueButtonStyle {
        BlueButtonStyle()
    }
    
    static var blueSmall: BlueButtonStyle {
        BlueButtonStyle(isSmall: true)
    }
}