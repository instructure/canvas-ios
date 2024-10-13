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

struct BadgeModifier<Content: View>: View {
    let value: Int
    let content: Content

    var body: some View {
        content.overlay(GeometryReader { geometry in
            Text(NumberFormatter.localizedString(from: NSNumber(value: value), number: .none))
                .font(.system(size: 10, weight: .semibold)).foregroundColor(.textLightest.variantForLightMode)
                .frame(minWidth: 14, maxHeight: 14)
                .background(RoundedRectangle(cornerRadius: 7).stroke(Color.backgroundLightest, lineWidth: 2))
                .background(RoundedRectangle(cornerRadius: 7).fill(Color.backgroundInfo))
                .position(x: geometry.size.width - 2, y: 2)
        })
    }
}

extension View {
    @ViewBuilder
    public func badge(_ value: Int?) -> some View {
        if let value = value {
            BadgeModifier(value: value, content: self)
        } else {
            self
        }
    }
}
