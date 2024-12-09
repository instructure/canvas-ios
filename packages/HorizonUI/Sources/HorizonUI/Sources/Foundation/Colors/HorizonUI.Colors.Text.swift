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

public extension HorizonUI.Colors {
    struct TextColor: Sendable, ColorCollection {

        let author = Color(.textAuthor)
        let beigePrimary = Color(.textBeigePrimary)
        let beigeSecondary = Color(.textBeigeSecondary)
        let body = Color(.textBody)
        let dataPoint = Color(.dataPoint)
        let link = Color(.textLink)
        let linkSecondary = Color(.linkSecondary)
        let placeholder = Color(.textPlaceholder)
        let surfaceColored = Color(.textSurfaceColored)
        let surfaceInverseSecondary = Color(.textSurfaceInverseSecondary)
        let textError = Color(.textError)
        let textSuccess = Color(.textSuccess)
        let textWarning = Color(.textWarning)
        let timestamp = Color(.textTimestamp)
        let title = Color(.textTitle)
        var allColors: [ColorWithID] = []

        init() {
            self.allColors = extractColorsWithIDs()
        }
    }    
}
