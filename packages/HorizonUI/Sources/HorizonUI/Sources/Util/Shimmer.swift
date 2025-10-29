//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public struct Shimmer: ViewModifier {
    @State private var isInitialState = true

    public init() {}
    public func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    gradient: .init(colors: [
                        .black.opacity(0.17),
                        .black.opacity(0.11),
                        .black.opacity(0.17)
                    ]),
                    startPoint: isInitialState ? .init(x: -0.3, y: -0.15) : .init(x: 1, y: 0.65),
                    endPoint: isInitialState ? .init(x: 0, y: 0) : .init(x: 1.3, y: 0.8)
                )
            )
            .animation(.easeInOut(duration: 1).delay(0.25).repeatForever(autoreverses: false), value: isInitialState)
            .onAppear {
                Task { @MainActor in
                    isInitialState = false
                }
            }
    }
}
