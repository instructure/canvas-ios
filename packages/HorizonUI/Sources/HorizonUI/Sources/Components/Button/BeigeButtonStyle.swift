import SwiftUI

struct BeigeButtonStyle: ThemedButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    let isSmall: Bool
    
    init(isSmall: Bool = false) {
        self.isSmall = isSmall
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .frame(height: size.height)
            .background(ButtonColors.beige)
            .foregroundStyle(ButtonColors.dark)
            .cornerRadius(size.cornerRadius)
            .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1.0) : 0.5)
    }
}

extension ButtonStyle where Self == BeigeButtonStyle {
    static var beige: BeigeButtonStyle {
        BeigeButtonStyle()
    }
    
    static var beigeSmall: BeigeButtonStyle {
        BeigeButtonStyle(isSmall: true)
    }
}
