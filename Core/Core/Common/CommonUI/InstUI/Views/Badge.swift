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

extension InstUI {

    struct BadgeModifier: ViewModifier {
        private let text: String?

        init(count: Int) {
            text = {
                switch count {
                case ...0:
                    return nil
                case 1..<100:
                    return "\(count)"
                default:
                    return "99+"
                }
            }()
        }

        func body(content: Content) -> some View {
            content
                .overlay {
                    GeometryReader { geometry in
                        if let text {
                            pill(text)
                                .position(x: geometry.size.width - 2, y: 2)
                                .transition(.push(from: .top))
                        }
                    }
                    .animation(.default, value: text)
                }
        }

        private func pill(_ text: String) -> some View {
            Text(text)
                .font(.semibold12)
                .padding(EdgeInsets(
                    top: 2.5,
                    leading: 6.5,
                    bottom: 3,
                    trailing: 6.5
                ))
                .foregroundColor(.textLightest)
                .background(Color.backgroundDanger)
                .clipShape(Capsule())
                .fixedSize(horizontal: true, vertical: false)
        }
    }
}

extension View {
    @ViewBuilder
    public func instBadge(_ count: Int?) -> some View {
        modifier(InstUI.BadgeModifier(count: count ?? 0))
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var badgeValueIndex: Int = 0
    let badgeValues: [Int?] = [nil, 1, 99, 100]

    VStack {
        HStack(spacing: 10) {
            Image.alertsTab.instBadge(nil)
            Image.alertsTab.instBadge(1)
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
