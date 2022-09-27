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

public struct RefreshableView<Content: View>: View {
    enum ViewState {
        case progress(CGFloat)
        case animating
    }

    var content: () -> Content
    var refreshAction: (@escaping () -> Void) -> Void

    @State private var isAnimating = false
    @State private var progress: CGFloat = 0
    @State private var viewState: ViewState = .animating
    @State private var offset: CGFloat = 0
    private let snappingPoint: CGFloat = 64
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)

    public var body: some View {
        VStack(spacing: 0) {
            switch viewState {
            case .animating:
                ProgressView()
                    .progressViewStyle(.indeterminateCircular)
                    .opacity(progress)
                    .padding(.top, 16)
                    .offset(x: 0, y: -offset)
            case let .progress(progress):
                ProgressView(value: progress)
                    .progressViewStyle(.determinateCircular)
                    .opacity(progress)
                    .padding(.top, 16)
                    .offset(x: 0, y: -offset)
            }
            content()
                .offset(x: 0, y: isAnimating ? 0 : -48)
                .animation(.default, value: isAnimating)
        }
        .background(
            GeometryReader {
                Color.clear.preference(
                    key: ViewOffsetKey.self,
                    value: $0.frame(in: .global).origin.y
                )
            }
        )
        .onPreferenceChange(ViewOffsetKey.self) { newValue in
            let newOffset = newValue - 91
            guard newOffset >= 0 else {
                isAnimating = false
                offset = 0
                return
            }
            offset = newOffset

            guard !isAnimating else { return }
            progress = min(abs(offset / snappingPoint), 1)
            viewState = .progress(progress)
            if progress == 1 {
                let triggerStartDate = Date()
                hapticGenerator.impactOccurred()
                isAnimating = true
                viewState = .animating

                refreshAction {
                    let triggerEndDate = Date()
                    let timeElapsed = triggerEndDate.timeIntervalSince1970 - triggerStartDate.timeIntervalSince1970
                    let additionalDuration = 1 - timeElapsed
                    DispatchQueue.main.asyncAfter(deadline: .now() + additionalDuration) {
                        isAnimating = false
                        progress = 0
                    }
                }
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
