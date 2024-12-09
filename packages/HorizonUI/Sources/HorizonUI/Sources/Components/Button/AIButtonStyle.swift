import SwiftUI

struct AIButtonStyle: ThemedButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    let isSmall: Bool
    
    init(isSmall: Bool = false) {
        self.isSmall = isSmall
    }
    
    func makeBody(configuration: Configuration) -> some View {
        baseButtonStyle(configuration.label, isPressed: configuration.isPressed, isEnabled: isEnabled)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        ButtonColors.AI.gradientTop,
                        ButtonColors.AI.gradientBottom
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .foregroundStyle(ButtonColors.white)
            .cornerRadius(size.cornerRadius)
            .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1.0) : 0.5)
    }
}

extension ButtonStyle where Self == AIButtonStyle {
    static var ai: AIButtonStyle {
        AIButtonStyle()
    }
    
    static var aiSmall: AIButtonStyle {
        AIButtonStyle(isSmall: true)
    }
}