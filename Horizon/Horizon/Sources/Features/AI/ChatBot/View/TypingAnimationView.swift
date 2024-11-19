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
import Core

struct TypingAnimationView: View {
    // MARK: - Properties

    private let circleSize: CGFloat = 10
    private let spacing: CGFloat = 4
    private let animationDuration: Double = 0.6
    private let circleCount = 3
    @State private var animate = false

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<circleCount, id: \.self) { index in
                Circle()
                    .frame(width: circleSize, height: circleSize)
                    .scaleEffect(animate ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: animationDuration)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
        .foregroundColor(Color.backgroundLightest)
        .padding()
        .background(Color.backgroundLightest.opacity(0.2))
        .cornerRadius(16)
        .frame(maxWidth: 250, alignment: .leading)
    }
}

#if DEBUG
#Preview {
    TypingAnimationView()
}
#endif
