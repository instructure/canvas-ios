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

import Core
import SwiftUI

struct ProgramsView: View {
    @ObservedObject private var viewModel: ProgramsViewModel
    @State private var scrollPos: Int?

    init(viewModel: ProgramsViewModel) {
        self.viewModel = viewModel
        scrollPos = 0
    }

    var body: some View {
        BaseHorizonScreen {
            InstUI.BaseScreen(
                state: viewModel.state,
                config: .init(refreshable: false)
            ) { proxy in
                VStack(alignment: .leading, spacing: 0) {
                    if let program = viewModel.programs.first(where: { !$0.modules.isEmpty }) {
                        Size24BoldTextDarkestTitle(title: program.name)
                            .padding(.bottom, 4)
                        Size12RegularTextDarkTitle(title: program.institutionName)
                            .padding(.bottom, 4)
                        Size12RegularTextDarkTitle(title: program.targetCompletion)
                        CertificateProgressBar(
                            maxWidth: proxy.size.width,
                            progress: program.progress,
                            progressString: program.progressString
                        )
                        .padding(.bottom, 16)
                        learningContentView(modules: program.modules)
                    }
                }
                .background(Color.backgroundLight)
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
        }
        .background(Color.backgroundLight)
        .onFirstAppear {
            scrollPos = 0
        }
    }

    @ViewBuilder
    private func learningContentView(modules: [HModule]) -> some View {
        VStack {
            courseSelectorView
            moduleListView(modules: modules)
            Spacer()
        }
//        .containerRelativeFrame(.vertical)
    }

    private var courseSelectorView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0 ..< 6) { index in
                    Button {
                        scrollPos = index
                    } label: {
                        VStack {
                            Size14RegularTextDarkestTitle(title: "Course: \(index)")
                            if index == scrollPos {
                                Rectangle()
                                    .foregroundColor(Color.red)
                                    .frame(height: 2)
                            }
                        }
                        .frame(maxHeight: 44)
                    }
                    .id(index)
                }
            }
        }
        .scrollTargetLayout()
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
        .scrollBounceBehavior(.basedOnSize)
        .scrollPosition(id: $scrollPos, anchor: .center)
        .animation(.smooth, value: scrollPos)
    }

    @ViewBuilder
    private func moduleListView(modules: [HModule]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0 ..< 6) { index in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(modules) { module in
                                ExpandingModuleView(
                                    title: module.name,
                                    items: module.items
                                )
                                .frame(minHeight: 44)
                                .background(Color.backgroundLightest)
                                .cornerRadius(8)
                                .id(index)
                            }
                        }
                    }
                    .containerRelativeFrame(.horizontal)
                    .id(index)
                    .scrollTransition(.interactive) { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .offset(
                                x: phase.isIdentity ? 0 : -16,
                                y: phase.isIdentity ? 0 : -100
                            )
                    }
                }
            }
        }
        .scrollTargetLayout()
        .scrollTargetBehavior(.viewAligned)
        .scrollBounceBehavior(.basedOnSize)
        .scrollPosition(id: $scrollPos, anchor: .center)
        .animation(.smooth, value: scrollPos)
    }
}
