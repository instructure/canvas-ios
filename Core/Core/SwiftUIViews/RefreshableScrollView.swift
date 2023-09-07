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

public struct RefreshableScrollView<Content: View>: View {
    private enum ViewState {
        case progress(CGFloat)
        case animating
    }

    // MARK: - Dependencies

    private let axes: Axis.Set
    private let showsIndicators: Bool
    private let content: () -> Content
    private let refreshAction: (@escaping () -> Void) -> Void

    // MARK: - Private properties

    @State private var canStartNewRefresh = false
    @State private var isAnimating = false
    @State private var progress: CGFloat = 0
    @State private var viewState: ViewState = .animating
    @State private var offset: CGFloat = 0
    private let topPadding: CGFloat = 16
    private let bottomPadding: CGFloat = 8
    private let progressViewSize: CGFloat = 32
    private let snappingPoint: CGFloat = 64
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)
    private var totalProgressHeight: CGFloat { progressViewSize + topPadding + bottomPadding }
    private var contentOffset: CGFloat {
        guard isAnimating, offset < totalProgressHeight else { return 0 }
        return totalProgressHeight - offset
    }

    // MARK: - Init

    public init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        @ViewBuilder content: @escaping () -> Content,
        refreshAction: @escaping (@escaping () -> Void) -> Void
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content
        self.refreshAction = refreshAction
    }

    public var body: some View {
        ZStack(alignment: .top) {
            switch viewState {
            case .animating:
                indeterminateProgressView()
            case let .progress(progress):
                determinateProgressView(progress)
            }
            ScrollView(
                axes,
                showsIndicators: showsIndicators,
                content: {
                    content()
                        .offset(x: 0, y: contentOffset)
                        .animation(.default, value: isAnimating)
                        .background(
                            GeometryReader {
                                Color.clear.preference(
                                    key: ViewOffsetKey.self,
                                    value: $0.frame(in: .named("frameLayer")).minY
                                )
                            }
                        )
                        .onPreferenceChange(ViewOffsetKey.self) { newValue in
                            updateState(offset: newValue)
                        }
                    Spacer()
                        .frame(height: 60)
                }
            )
            .coordinateSpace(name: "frameLayer")
        }
    }

    @ViewBuilder private func indeterminateProgressView() -> some View {
        ProgressView()
            .progressViewStyle(.indeterminateCircle(size: progressViewSize))
            .opacity(progress)
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
    }

    @ViewBuilder private func determinateProgressView(_ progress: CGFloat) -> some View {
        ProgressView(value: progress)
            .progressViewStyle(.determinateCircle())
            .opacity(progress)
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
    }

    private func updateState(offset newValue: ViewOffsetKey.Value) {
        if newValue == 0 {
            canStartNewRefresh = true
        }

        guard newValue >= 0 else {
            isAnimating = false
            offset = 0
            return
        }

        offset = newValue

        guard canStartNewRefresh, !isAnimating else { return }
        progress = min(abs(offset / snappingPoint), 1)
        viewState = .progress(progress)
        if progress == 1 {
            let triggerStartDate = Date()
            hapticGenerator.impactOccurred()
            isAnimating = true
            canStartNewRefresh = false
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

private struct ViewOffsetKey: PreferenceKey {
    public typealias Value = CGFloat
    public static var defaultValue = CGFloat.zero
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
