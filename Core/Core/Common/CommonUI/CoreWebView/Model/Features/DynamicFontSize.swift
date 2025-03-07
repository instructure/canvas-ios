//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

internal class DynamicFontSize: CoreWebViewFeature {
    private var script: String {
        let css = """
        body {
            -webkit-text-size-adjust: \(percentScale) !important
        }
        """

        let cssString = css.components(separatedBy: .newlines).joined()
        return """
           var element = document.createElement('style');
           element.innerHTML = '\(cssString)';
           document.head.appendChild(element);
        """
    }
    private var percentScale: String {
        let scale = Int(100 * UIScreen.main.traitCollection.preferredContentSizeCategory.fontScale)
        return "\(scale)%"
    }

    public override init() {}

    override func apply(on webView: CoreWebView) {
        webView.addScript(script)
    }
}

extension CoreWebViewFeature {

    /**
     This feature adds a CSS override that re-scales fonts based on the system's dynamic font size setting.
     Note: it doesn't re-apply the scale if the dynamic size setting change while the webview is already presented.
     */
    public static var dynamicFontSize: CoreWebViewFeature {
        DynamicFontSize()
    }
}

private extension UIContentSizeCategory {
    static var allCases: [UIContentSizeCategory] {
        [
            .extraSmall,
            .small,
            .medium,
            .large,
            .extraLarge,
            .extraExtraLarge,
            .extraExtraExtraLarge,
            .accessibilityMedium,
            .accessibilityLarge,
            .accessibilityExtraLarge,
            .accessibilityExtraExtraLarge,
            .accessibilityExtraExtraExtraLarge,
        ]
    }

    var fontScale: CGFloat {
        switch self {
        case .extraSmall: return 0.87
        case .small: return 0.94
        case .medium: return 0.95
        case .large: return 1.0
        case .extraLarge: return 1.07
        case .extraExtraLarge: return 1.2
        case .extraExtraExtraLarge: return 1.33
        case .accessibilityMedium: return 1.55
        case .accessibilityLarge: return 1.81
        case .accessibilityExtraLarge: return 2.2
        case .accessibilityExtraExtraLarge: return 2.58
        case .accessibilityExtraExtraExtraLarge: return 2.82
        default: return 1.0
        }
    }
}

/// The purpose of this preview is to get an estimation of how each content size category affects font size.
/// You need to modify the fontScale values above until the two strings are the same size.
@available(iOS 17.0, *)
#Preview(traits: .fixedLayout(width: 400, height: 1200)) {
    let referenceFontSize: CGFloat = 16.0

    let verticalStack = UIStackView()
    verticalStack.axis = .vertical

    for contentSizeCategory in UIContentSizeCategory.allCases {
        let scale = contentSizeCategory.fontScale
        let scaledFontSize = referenceFontSize * scale
        let percentageString = String(format: "%.0f%%", scale * 100)

        let categoryTitle = UILabel()
        categoryTitle.text = "\(contentSizeCategory.rawValue.deletingPrefix("UICTContentSizeCategory")) - \(percentageString)"
        verticalStack.addArrangedSubview(categoryTitle)

        let systemFont = UIFontMetrics(forTextStyle: .body)
            .scaledFont(
                for: UIFont.systemFont(ofSize: referenceFontSize),
                compatibleWith: UITraitCollection(preferredContentSizeCategory: contentSizeCategory)
            )
        let systemSizedLabel = UILabel()
        systemSizedLabel.font = systemFont
        systemSizedLabel.text = "Lorem Ipsum"
        verticalStack.addArrangedSubview(systemSizedLabel)

        let scaledSizeLabel = UILabel()
        scaledSizeLabel.font = UIFont.systemFont(ofSize: scaledFontSize)
        scaledSizeLabel.text = "Lorem Ipsum"

        verticalStack.addArrangedSubview(scaledSizeLabel)

        let divider = UIView()
        divider.heightAnchor.constraint(equalToConstant: 20).isActive = true
        verticalStack.addArrangedSubview(divider)
    }

    return verticalStack
}
