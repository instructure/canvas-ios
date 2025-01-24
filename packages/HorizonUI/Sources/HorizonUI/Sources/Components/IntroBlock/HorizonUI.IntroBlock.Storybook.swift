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

public extension HorizonUI.IntroBlock {
    struct Storybook: View {
        @State private var isShowHeader = true
        @Environment(\.dismiss) private var dismiss

        public var body: some View {
            ZStack {
                Color.huiColors.surface.institution
                    .ignoresSafeArea(edges: .top)

                contentView
                    .ignoresSafeArea(edges: .bottom)
                    .padding(.top, 1)
            }
            .navigationBarHidden(true)
            .safeAreaInset(edge: .top, spacing: .zero) {
                if isShowHeader {
                    HorizonUI.IntroBlock(
                        moduleName: "Module Name Amet Adipiscing Elit ",
                        moduleItemName: "Learning Object Name Lorem Ipsum Dolor Learning Object",
                        duration: "XX Mins",
                        dueDate: "Due XX/XX",
                        onBack: {dismiss()},
                        onMenu: {}
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.linear, value: isShowHeader)
        }

        private var contentView: some View {
            VStack(spacing: .zero) {
                ScrollView {
                    topView
                    VStack {
                        ForEach(0..<10) { _ in
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.green)
                                .frame(height: 200)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 5)
                    }
                }
                .background(.white)
                .huiCornerRadius(level: .level5, corners: [.topRight, .topLeft])
            }
        }
        private var topView: some View {
            Color.clear
                .frame(height: 0)
                .readingFrame { frame in
                    isShowHeader = frame.minY > 0
                }
        }
    }
}

#Preview {
    HorizonUI.IntroBlock.Storybook()
}

// TODO: - This for make the Storybook & will remove later
struct FrameReader: View {
    // MARK: - Dependencies

    let coordinateSpace: CoordinateSpace
    let onChange: (_ frame: CGRect) -> Void

    // MARK: - Init

    init(
        coordinateSpace: CoordinateSpace,
        onChange: @escaping (_ frame: CGRect) -> Void
    ) {
        self.coordinateSpace = coordinateSpace
        self.onChange = onChange
    }

    var body: some View {
        GeometryReader { geometry in
            Text("")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: geometry.frame(in: coordinateSpace)) { _, newState in
                    onChange(newState)
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension View {
    func readingFrame(
        coordinateSpace: CoordinateSpace = .global,
        onChange: @escaping (_ frame: CGRect) -> Void
    ) -> some View {
        background(
            FrameReader(coordinateSpace: coordinateSpace, onChange: onChange)
        )
    }
}
