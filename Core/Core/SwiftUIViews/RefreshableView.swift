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

struct RefreshableView<Content: View>: View {
    var content: () -> Content
    var refreshAction: (@escaping () -> Void) -> Void

    @State private var isVisible = false
    @State private var isAnimating = false
    @State private var progress: CGFloat = 0
    @State private var viewState: CircularProgressView.ViewState = .animating
    @State private var offset: CGFloat = 0
    private let snappingPoint: CGFloat = 64
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        VStack(spacing: 0) {
            if isVisible {
                CircularProgressView(viewState: $viewState)
                    .padding(.vertical, 16)
                    .offset(x: 0, y: -offset)
            }
            content()
                .offset(x: 0, y: isVisible ? -CircularProgressView.size : 0)
        }
        .animation(.default, value: isVisible)
        .background(
            GeometryReader {
                Color.clear.preference(
                    key: ViewOffsetKey.self,
                    value: $0.frame(in: .global).origin.y
                )
            }
        )
        .onPreferenceChange(ViewOffsetKey.self) { newValue in
            offset = newValue - 91
            guard !isAnimating else { return }
            progress = min(abs((newValue - 91) / snappingPoint), 1)
            viewState = .progress(progress)
            isVisible = progress > 0
            if progress == 1 {
                hapticGenerator.impactOccurred()
                isAnimating = true
                viewState = .animating
                refreshAction {
                    isVisible = false
                    isAnimating = false
                    progress = 0
                }
            }
        }
    }
}

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

private struct ViewOffsetKey: PreferenceKey {
    public typealias Value = CGFloat
    public static var defaultValue = CGFloat.zero
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
