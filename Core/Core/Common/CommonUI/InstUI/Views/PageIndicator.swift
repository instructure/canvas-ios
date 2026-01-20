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

extension InstUI {

    public struct PageIndicator: View {

        // MARK: - Private Properties

        @ScaledMetric private var uiScale: CGFloat = 1
        private let currentIndex: Int
        private let count: Int
        private let maxDotsBeforeScroll: Int
        private var dotSize: CGFloat { 8 * uiScale.iconScale }
        private var selectedDotSize: CGFloat { 20 * uiScale.iconScale }
        private var spacing: CGFloat { 4 * uiScale.iconScale }
        private var edgePadding: CGFloat { 20 * uiScale.iconScale }

        private static let fadeGradient = LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: 0.15),
                .init(color: .black, location: 0.85),
                .init(color: .clear, location: 1)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )

        // MARK: - Public Interface

        public init(
            currentIndex: Int,
            count: Int,
            maxDotsBeforeScroll: Int = 7
        ) {
            self.currentIndex = currentIndex
            self.count = count
            self.maxDotsBeforeScroll = maxDotsBeforeScroll
        }

        public var body: some View {
            if count > 1 {
                indicator
            }
        }

        // MARK: - Private Helpers

        @ViewBuilder
        private var indicator: some View {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing) {
                        ForEach(0 ..< count, id: \.self) { index in
                            dotView(isSelected: index == currentIndex)
                                .id(index)
                        }
                    }
                    .padding(.horizontal, edgePadding)
                    .frame(minWidth: viewportWidth)
                }
                .scrollDisabled(true)
                .mask(Self.fadeGradient)
                .onChange(of: currentIndex) { _, newIndex in
                    withAnimation(.smooth) {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
                .onAppear {
                    proxy.scrollTo(currentIndex, anchor: .center)
                }
            }
            .frame(width: viewportWidth, height: dotSize)
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
        }

        private var viewportWidth: CGFloat {
            CGFloat(maxDotsBeforeScroll - 1) * (dotSize + spacing) + selectedDotSize + 2 * edgePadding
        }

        private func dotView(isSelected: Bool) -> some View {
            Capsule()
                .fill(isSelected ? Color.textDarkest : Color.borderMedium)
                .frame(width: isSelected ? selectedDotSize : dotSize, height: dotSize)
                .animation(.smooth, value: currentIndex)
        }
    }
}

#if DEBUG

extension InstUI.PageIndicator {
    struct Storybook: View {
        var body: some View {
            PageIndicatorPreview()
                .navigationTitle(Text(verbatim: "Page Indicator"))
                .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    PageIndicatorPreview()
}

private struct PageIndicatorPreview: View {
    @State private var currentPage = 0
    @State private var pageCount = 4
    @State private var maxDotsBeforeScroll = 7

    var body: some View {
        VStack(spacing: 20) {
            InstUI.PageIndicator(currentIndex: currentPage, count: pageCount, maxDotsBeforeScroll: maxDotsBeforeScroll)

            VStack(spacing: 10) {
                Text(verbatim: "Helper controls")

                InstUI.Divider()

                HStack(spacing: 12) {
                    Button {
                        if currentPage > 0 {
                            currentPage -= 1
                        }
                    } label: {
                        Text(verbatim: "Prev")
                    }
                    .disabled(currentPage == 0)

                    Button {
                        if currentPage < pageCount - 1 {
                            currentPage += 1
                        }
                    } label: {
                        Text(verbatim: "Next")
                    }
                    .disabled(currentPage == pageCount - 1)
                }

                Text(verbatim: "Page \(currentPage + 1) of \(pageCount)")

                InstUI.Divider()

                HStack(spacing: 12) {
                    Button {
                        currentPage = 0
                        pageCount = 4
                    } label: {
                        Text(verbatim: "4 Pages")
                    }

                    Button {
                        currentPage = 0
                        pageCount = 15
                    } label: {
                        Text(verbatim: "15 Pages")
                    }
                }

                InstUI.Divider()

                HStack(spacing: 12) {
                    Button {
                        maxDotsBeforeScroll = 3
                    } label: {
                        Text(verbatim: "3 Max")
                    }

                    Button {
                        maxDotsBeforeScroll = 5
                    } label: {
                        Text(verbatim: "5 Max")
                    }

                    Button {
                        maxDotsBeforeScroll = 7
                    } label: {
                        Text(verbatim: "7 Max")
                    }

                    Button {
                        maxDotsBeforeScroll = 10
                    } label: {
                        Text(verbatim: "10 Max")
                    }
                }

                Text(verbatim: "Max dots before scroll: \(maxDotsBeforeScroll)")
            }
            .padding()
            .border(Color.borderDark)
        }
        .padding()
    }
}

#endif
