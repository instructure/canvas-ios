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

@available(iOSApplicationExtension 13.0.0, *)
public struct CircleProgress: UIViewRepresentable {
    public let progress: CGFloat?

    public init(progress: CGFloat? = nil) {
        self.progress = progress
    }

    public func makeUIView(context: Self.Context) -> CircleProgressView {
        let uiView = CircleProgressView()
        return uiView
    }

    public func updateUIView(_ uiView: CircleProgressView, context: Self.Context) {
        uiView.updateSize()
        uiView.progress = progress
    }

    public func size(_ diameter: CGFloat = 40) -> some View {
        frame(width: diameter, height: diameter)
    }
}

#if DEBUG
@available(iOSApplicationExtension 13.0.0, *)
struct CircleProgress_Previews: PreviewProvider {
    static var previews: some View {
        CircleProgress(progress: nil)
    }
}
#endif
