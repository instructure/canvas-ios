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

public struct CircularProgressView: View {
    @Binding public private(set) var viewState: ViewState
    @State private var isVisible = false
    public static let size: CGFloat = 32

    public enum ViewState {
        case progress(CGFloat)
        case animating
    }

    public var body: some View {
        ZStack {
            switch viewState {
            case .animating:
                Circle()
                    .stroke(
                        Color.borderLight,
                        lineWidth: 3
                    )
                    .frame(width: Self.size, height: Self.size)
                Circle()
                    .trim(from: 0.15, to: 1)
                    .stroke(
                        Color.blue,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: Self.size, height: Self.size)
                    .rotationEffect(Angle(degrees: isVisible ? 359 : 0))
                    .animation(
                        .linear(duration: 2)
                            .repeatForever(autoreverses: false),
                        value: isVisible
                    )
                    .transition(.scale)
                    .onAppear {
                        isVisible = true
                    }
            case .progress(let progress):
                Circle()
                    .stroke(
                        Color.borderLight,
                        lineWidth: 3
                    )
                    .frame(width: Self.size, height: Self.size)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.blue,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: Self.size, height: Self.size)
                    .rotationEffect(.degrees(-90))
                    .animation(.none, value: progress)
                    .transition(.scale)
            }
        }
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(viewState: .constant(.animating))
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)
        CircularProgressView(viewState: .constant(.animating))
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)

        CircularProgressView(viewState: .constant(.progress(0.25)))
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)
        CircularProgressView(viewState: .constant(.progress(0.25)))
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
