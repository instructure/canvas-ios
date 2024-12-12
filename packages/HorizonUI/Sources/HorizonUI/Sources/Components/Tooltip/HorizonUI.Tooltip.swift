import SwiftUI
import TipKit

public extension HorizonUI {
    struct Tooltip: View {
        private let text: String
        private let style: TooltipStyle
        private let tip: TooltipTip

        public init(
            text: String,
            style: TooltipStyle = .dark
        ) {
            self.text = text
            self.style = style
            self.tip = TooltipTip(text: text)
        }

        public var body: some View {
            TipView(tip) {_ in 
                TooltipContent(text: text, style: style)
            }
        }
    }
}

// MARK: - Tooltip Tip
private struct TooltipTip: Tip {
    var title: Text
    
    let text: String

    var rules: [Rule] {
        [
            Tips.Rule.oncePerSession
        ]
    }

    var options: [TipOption] {
        [
            Tips.MaxDisplayCount(1)
        ]
    }
}

// MARK: - Tooltip Content
private struct TooltipContent: View {
    let text: String
    let style: HorizonUI.Tooltip.TooltipStyle

    var body: some View {
        HorizonUI.Typography(
            text: text,
            name: .p2,
            color: style.textColor
        )
        .padding(8)
        .background(style.backgroundColor)
        .cornerRadius(8)
    }
}

// MARK: - Tooltip Style
public extension HorizonUI.Tooltip {
    enum TooltipStyle {
        case dark
        case light

        var backgroundColor: Color {
            switch self {
            case .dark:
                return Color(red: 10/255, green: 27/255, blue: 42/255)
            case .light:
                return .white
            }
        }

        var textColor: Color {
            switch self {
            case .dark:
                return .white
            case .light:
                return Color(red: 39/255, green: 53/255, blue: 64/255)
            }
        }
    }
}
