//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Combine
import SwiftUI

class DashboardLayoutViewModel: ObservableObject {
    public struct LayoutInfo {
        let columns: Int
        let cardWidth: CGFloat
        let cardMinHeight: CGFloat
        let spacing: CGFloat
        let isWideLayout: Bool
    }
    public static let Spacing: CGFloat = 16

    private let interactor: DashboardSettingsInteractor
    private var subscriptions = Set<AnyCancellable>()

    public init(interactor: DashboardSettingsInteractor) {
        self.interactor = interactor
        triggerUIRefreshOnLayoutChange()
    }

    public func layoutInfo(for width: CGFloat, horizontalSizeClass: UserInterfaceSizeClass?) -> LayoutInfo {
        let columns: CGFloat = {
            if interactor.layout.value == .grid {
                return width >= 635 ? 4 : 2
            } else {
                return 1
            }
        }()
        var cardWidth: CGFloat = (width - ((columns - 1) * Self.Spacing)) / columns
        // When split view transforms from single screen to split the reported width is 0 which causes card
        // widths to be negative and raises SwiftUI warnings. We make sure the width is something valid.
        cardWidth = max(cardWidth, 50)

        let minHeight: CGFloat = {
            if horizontalSizeClass == .regular, interactor.layout.value == .list {
                return 100
            } else {
                return 160
            }
        }()
        let isWideLayout = horizontalSizeClass == .regular && interactor.layout.value == .list

        return LayoutInfo(columns: Int(columns),
                          cardWidth: cardWidth,
                          cardMinHeight: minHeight,
                          spacing: Self.Spacing,
                          isWideLayout: isWideLayout)
    }

    private func triggerUIRefreshOnLayoutChange() {
        interactor
            .layout
            .removeDuplicates()
            .sink { [objectWillChange] _ in
                withAnimation {
                    objectWillChange.send()
                }
            }
            .store(in: &subscriptions)
    }
}
