//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public struct ScrollViewWithReader<Content>: View where Content: View {
    private let contentBuilder: (ScrollViewProxy) -> Content
    private let axes: Axis.Set
    private let showsIndicators: Bool

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(axes, showsIndicators: showsIndicators) {
                contentBuilder(proxy)
            }
        }
    }

    public init(_ axes: Axis.Set = .vertical, showsIndicators: Bool = true, @ViewBuilder contentBuilder: @escaping (ScrollViewProxy) -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.contentBuilder = contentBuilder
    }
}
