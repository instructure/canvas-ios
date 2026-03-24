//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

extension Image {
    @ViewBuilder
    static func desaturated(_ name: String, bundle: Bundle) -> some View {
        if #available(iOS 26, *) {
            Image(name, bundle: bundle)
                .widgetAccentedRenderingMode(.desaturated)
        } else {
            Image(name, bundle: bundle)
        }
    }

    @ViewBuilder
    static func resizableDesaturated(_ name: String, bundle: Bundle) -> some View {
        if #available(iOS 26, *) {
            Image(name, bundle: bundle)
                .resizable()
                .widgetAccentedRenderingMode(.desaturated)
        } else {
            Image(name, bundle: bundle)
                .resizable()
        }
    }
}
