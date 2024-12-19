//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public extension HorizonUI.NavigationBar {
    struct Trailing: View {
        public enum Event {
            case mail
            case notebook
            case notification
        }

        private let onEvent: (Event) -> Void

        public init(onEvent: @escaping (Event) -> Void) {
            self.onEvent = onEvent
        }

        public var body: some View {
            HStack(spacing: .zero) {
                Button {
                    onEvent(.notebook)
                } label: {
                    Image.huiIcons.menuBookNotebook
                        .dropShadow()
                }

                Button {
                    onEvent(.notification)
                } label: {
                    Image.huiIcons.notificationsUnread
                        .dropShadow()
                }

                Button {
                    onEvent(.mail)
                } label: {
                    Image.huiIcons.mail
                        .dropShadow()
                }
            }
        }
    }
}

#Preview {
    HorizonUI.NavigationBar.Trailing { _ in }
}

fileprivate extension HorizonUI.NavigationBar.Trailing {
    struct DropShadowModifire: ViewModifier {
        func body(content: Content) -> some View {
            content
                .foregroundStyle(Color.huiColors.icon.default)
                .frame(width: 44, height: 44)
                .background {
                    Rectangle()
                        .fill(Color.huiColors.surface.pageSecondary)
                        .huiCornerRadius(level: .level6)
                        .huiElevation(level: .level4)
                }
        }
    }
}

fileprivate extension View {
    func dropShadow() -> some View {
        modifier(HorizonUI.NavigationBar.Trailing.DropShadowModifire())
    }
}

public extension HorizonUI {
    struct NavigationBar {}
}
