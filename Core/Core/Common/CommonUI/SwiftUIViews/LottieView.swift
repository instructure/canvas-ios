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
import Lottie

public struct LottieView: UIViewRepresentable {
    private let name: String
    private let bundle: Bundle
    private let loopMode: LottieLoopMode

    public init(name: String, bundle: Bundle = .core, loopMode: LottieLoopMode = .playOnce) {
        self.name = name
        self.bundle = bundle
        self.loopMode = loopMode
    }

    public func makeUIView(context: Self.Context) -> UIView {
        let animationView = LottieAnimationView(name: name, bundle: bundle)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.play()
        return animationView
    }

    public func updateUIView(_ uiView: UIView, context: Self.Context) {}
}

struct LottieView_Previews: PreviewProvider {
    static var previews: some View {
        LottieView(name: "confetti", loopMode: .loop)
    }
}
