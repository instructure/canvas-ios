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
    public typealias LayoutInfo = (columns: Int, cardWidth: CGFloat, spacing: CGFloat)
    public static let Spacing: CGFloat = 16

    @Published public private(set) var buttonImage: Image = .dashboardLayoutGrid
    @Published public private(set) var buttonA11yLabel: String = ""
    @Environment(\.appEnvironment) private var env
    private var isDashboardLayoutGrid: Bool = false {
        didSet {
            updateButton()
            saveStateToUserdefaults()
        }
    }

    public init() {
        isDashboardLayoutGrid = env.userDefaults?.isDashboardLayoutGrid ?? true
        updateButton()
        logAnalytics()
    }

    public func toggle() {
        isDashboardLayoutGrid.toggle()
    }

    public func layoutInfo(for width: CGFloat) -> LayoutInfo {
        let isWideLayout = (width >= 635)
        let columns: CGFloat = {
            if isDashboardLayoutGrid {
                return isWideLayout ? 4 : 2
            } else {
                return 1
            }
        }()
        var cardWidth: CGFloat = (width - ((columns - 1) * Self.Spacing)) / columns
        // When split view transforms from single screen to split the reported width is 0 which causes card
        // widths to be negative and raises SwiftUI warnings. We make sure the width is something valid.
        cardWidth = max(cardWidth, 50)
        return (columns: Int(columns), cardWidth: cardWidth, spacing: Self.Spacing)
    }

    private func updateButton() {
        withAnimation {
            buttonImage = (isDashboardLayoutGrid ? .dashboardLayoutList : .dashboardLayoutGrid)
            buttonA11yLabel = isDashboardLayoutGrid ? NSLocalizedString("Change dashboard layout to list", comment: "") : NSLocalizedString("Change dashboard layout to grid", comment: "")
        }
    }

    private func saveStateToUserdefaults() {
        env.userDefaults?.isDashboardLayoutGrid = isDashboardLayoutGrid
    }

    private func logAnalytics() {
        let type = isDashboardLayoutGrid ? "grid" : "list"
        Analytics.shared.logEvent("dashboard_layout", parameters: ["type": type])
    }
}
