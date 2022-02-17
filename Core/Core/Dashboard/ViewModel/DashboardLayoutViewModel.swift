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

    private static let DefaultSpacing: CGFloat = 16

    @Published public private(set) var buttonImage: Image = .dashboardLayoutGrid

    private var dashboardLayoutIsGrid: Bool = false {
        didSet {
            updateButtonImage()
            saveStateToUserdefaults()
        }
    }

    public init() {
        updateButtonImage()
    }

    public func toggle() {
        dashboardLayoutIsGrid.toggle()
    }

    public func layoutInfo(for width: CGFloat) -> LayoutInfo {
        let isWideLayout = (width >= 635)
        let columns: CGFloat = {
            if dashboardLayoutIsGrid {
                return isWideLayout ? 4 : 2
            } else {
                return isWideLayout ? 2 : 1
            }
        }()
        let cardWidth: CGFloat = (width - ((columns - 1) * Self.DefaultSpacing)) / columns
        return (columns: Int(columns), cardWidth: cardWidth, spacing: Self.DefaultSpacing)
    }
    
    private func updateButtonImage() {
        buttonImage = (dashboardLayoutIsGrid ? .dashboardLayoutList : .dashboardLayoutGrid)
    }

    private func saveStateToUserdefaults() {

    }
}
