//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import SwiftUI

extension View {

    /// - Parameters:
    ///   - style: Defines the badge's sizing and spacing values. This should match the host icon's size.
    ///   - isOverlayed:
    ///     - If `true`, the badge behaves like an `overlay` and the trailing part of the badge is ignored for horizontal layout.
    ///     - If `false`, the badge behaves like a `ZStack` and the trailing part of the badge is respected for horizontal layout.
    @ViewBuilder
    public func instBadge(
        _ count: Int?,
        style: InstUI.BadgeStyle = .hostSize24,
        isOverlayed: Bool = true,
        color: Color = .backgroundDanger
    ) -> some View {
        modifier(InstUI.BadgeModifier(count: count ?? 0, style: style, isOverlayed: isOverlayed, color: color))
    }
}

extension InstUI {

    public enum BadgeStyle {
        case hostSize24
        case hostSize18

        var offset: CGPoint {
            switch self {
            case .hostSize24: CGPoint(x: 10, y: -2)
            case .hostSize18: CGPoint(x: 6, y: -2)
            }
        }

        var edgeInsets: EdgeInsets {
            switch self {
            case .hostSize24: EdgeInsets(top: 2.5, leading: 6.5, bottom: 3, trailing: 6.5)
            case .hostSize18: EdgeInsets(top: 0.75, leading: 4, bottom: 1.25, trailing: 4)
            }
        }

        var borderWidth: CGFloat {
            switch self {
            case .hostSize24: 0
            case .hostSize18: 1
            }
        }

        var font: Font {
            switch self {
            case .hostSize24: .semibold12
            case .hostSize18: .regular10
            }
        }
    }

    struct BadgeModifier: ViewModifier {

        private let text: String?
        private let style: BadgeStyle
        private let isOverlayed: Bool
        private let color: Color

        @ScaledMetric(relativeTo: .body) private var uiScaleBody: CGFloat = 1
        @ScaledMetric(relativeTo: .caption2) private var uiScaleCaption2: CGFloat = 1
        private var uiScale: CGFloat {
            switch style {
            case .hostSize24: uiScaleBody
            case .hostSize18: uiScaleCaption2
            }
        }

        @State private var badgedContentWidth: CGFloat = 0

        init(count: Int, style: BadgeStyle, isOverlayed: Bool, color: Color) {
            text = switch count {
            case ...0:
                nil
            case 1..<100:
                "\(count)"
            default:
                "99+"
            }

            self.style = style
            self.isOverlayed = isOverlayed

            self.color = color
        }

        func body(content: Content) -> some View {
            content
                .hidden()
                .frame(width: isOverlayed ? nil : badgedContentWidth)
                .overlay(alignment: .bottomLeading) {
                    ZStack(alignment: .topTrailing) {
                        content
                        if let text {
                            let deltaX = style.offset.x * uiScale.iconScale
                            let deltaY = style.offset.y * uiScale.iconScale
                            pill(text)
                                .alignmentGuide(.trailing) { $0[HorizontalAlignment.leading] + deltaX }
                                .alignmentGuide(.top) { $0[VerticalAlignment.center] + deltaY }
                        }
                    }
                    .onSizeChange {
                        badgedContentWidth = $0.width
                    }
                }
        }

        private func pill(_ text: String) -> some View {
            Text(text)
                .font(style.font)
                .foregroundStyle(.textLightest)
                .padding(style.edgeInsets * uiScale)
                .background(
                    Capsule()
                        .fill(color)
                        .stroke(Color.textLightest, lineWidth: style.borderWidth)
                )
                .fixedSize(horizontal: true, vertical: false)
                .transition(.push(from: .top))
                .animation(.default, value: text)
        }
    }
}

#if DEBUG

#Preview {
    @Previewable @State var badgeValueIndex: Int = 0
    let badgeValues: [Int?] = [nil, 1, 99, 100]

    let clock18 = Image.clockLine.scaledIcon(size: 18)
    let doc18 = Image.documentLine.scaledIcon(size: 18)
    let menu24 = Image.hamburgerSolid.scaledIcon(size: 24)

    VStack {
        Divider()

        HStack(spacing: 10) {
            SwiftUI.Group {
                clock18.instBadge(nil, style: .hostSize18)
                clock18.instBadge(1, style: .hostSize18)
                clock18.instBadge(3, style: .hostSize18)
                clock18.instBadge(99, style: .hostSize18)
                clock18.instBadge(100, style: .hostSize18)
            }
            .background(.green)
        }
        Divider()

        HStack(spacing: 10) {
            clock18.instBadge(nil, style: .hostSize18)
            clock18.instBadge(1, style: .hostSize18)
            clock18.instBadge(3, style: .hostSize18)
            clock18.instBadge(99, style: .hostSize18)
            clock18.instBadge(100, style: .hostSize18)
        }
        Divider()

        HStack(spacing: 10) {
            doc18.instBadge(nil, style: .hostSize18)
            doc18.instBadge(1, style: .hostSize18)
            doc18.instBadge(3, style: .hostSize18)
            doc18.instBadge(99, style: .hostSize18)
            doc18.instBadge(100, style: .hostSize18)
        }
        Divider()

        HStack(spacing: 10) {
            menu24.instBadge(nil, style: .hostSize24)
            menu24.instBadge(1, style: .hostSize24)
            menu24.instBadge(3, style: .hostSize24)
            menu24.instBadge(99, style: .hostSize24)
            menu24.instBadge(100, style: .hostSize24)
        }
        Divider()

        HStack(spacing: 10) {
            Image.alertsTab.instBadge(nil)
            Image.alertsTab.instBadge(1)
            Image.alertsTab.instBadge(3)
            Image.alertsTab.instBadge(99)
            Image.alertsTab.instBadge(100)
        }
        Divider()

        HStack {
            Button {
                if badgeValueIndex == badgeValues.count - 1 {
                    badgeValueIndex = 0
                } else {
                    badgeValueIndex += 1
                }
            } label: {
                Text(verbatim: "Change!")
            }
            Image.alertsTab.instBadge(badgeValues[badgeValueIndex])
        }
    }
    .background(Color.backgroundLightest)
}

#endif
