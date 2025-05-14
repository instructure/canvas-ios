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

extension View {
    public func readingFrame(
        coordinateSpace: CoordinateSpace = .global,
        onChange: @escaping (_ frame: CGRect) -> Void
    ) -> some View {
        background(
            FrameReader(coordinateSpace: coordinateSpace, onChange: onChange)
        )
    }
}

public struct FrameReader: View {

    // MARK: - Properties
    let coordinateSpace: CoordinateSpace
    let onChange: (_ frame: CGRect) -> Void

    // MARK: - Init
    public init(coordinateSpace: CoordinateSpace, onChange: @escaping (_ frame: CGRect) -> Void) {
        self.coordinateSpace = coordinateSpace
        self.onChange = onChange
    }

    // MARK: - Body
    public var body: some View {
        GeometryReader { geometry in
            Text("")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    onChange(geometry.frame(in: coordinateSpace))
                }
                .onChange(of: geometry.frame(in: coordinateSpace)) {
                    onChange(geometry.frame(in: coordinateSpace))
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
