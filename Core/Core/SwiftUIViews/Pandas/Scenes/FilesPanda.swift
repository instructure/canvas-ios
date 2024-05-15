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

import SwiftUI

public struct FilesPanda: PandaScene {
    public var name: String { "files" }
    public var offset: (background: CGSize, foreground: CGSize) {(
        background: CGSize(width: 30, height: -8),
        foreground: CGSize(width: -30, height: 2))
    }
    public var height: CGFloat { 130 }
    public var background: AnyView { AnyView(Drawer(self)) }

    public init() {}
}

private struct Drawer: View {
    @State private var isClosed = true
    private let feedback = UIImpactFeedbackGenerator(style: .heavy)
    private let closedImage: Image
    private let openedImage: Image

    public init(_ scene: FilesPanda) {
        self.openedImage = Image(scene.backgroundFileName, bundle: .core)
        self.closedImage = Image("\(scene.backgroundFileName)-closed", bundle: .core)
    }

    public var body: some View {
        let tapAction = {
            withAnimation(.default.speed(2)) {
                isClosed.toggle()
            }

            feedback.impactOccurred()
        }
        closedImage
            .onTapGesture(perform: tapAction)
        openedImage
            .opacity(isClosed ? 0 : 1)
            .onTapGesture(perform: tapAction)
    }
}

struct FilesPanda_Previews: PreviewProvider {
    static var previews: some View {
        InteractivePanda(scene: FilesPanda())
    }
}
