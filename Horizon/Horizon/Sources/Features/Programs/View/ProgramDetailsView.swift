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

struct ProgramDetailsViewView: View {
    @ObservedObject private var viewModel: ProgramDetailsViewModel
    @State private var selectedCourseIndex: Int?
    @State private var selectedCourseDetailsIndex = 0

    init(viewModel: ProgramDetailsViewModel) {
        self.viewModel = viewModel
        self.selectedCourseIndex = 0
    }

    var body: some View {
        InstUI.BaseScreen(
            state: viewModel.state,
            config: .init(refreshable: false)
        ) { proxy in
            VStack(alignment: .leading, spacing: 0) {
                if let program = viewModel.program {
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
            .containerRelativeFrame(.vertical)
        }
        .containerRelativeFrame(.vertical)
        .safeAreaPadding(.bottom, 16)
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .background(Color.backgroundLight)
        .onFirstAppear {
            selectedCourseIndex = 0
        }
    }

    @ViewBuilder
    private func learningContentView(modules: [HModule]) -> some View {
        VStack {
            courseSelectorView
            moduleListView(modules: modules)
        }
        .background(Color.backgroundLight)
    }

    private var courseSelectorView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0 ..< 6) { index in
                    Button {
                        selectedCourseIndex = index
                        selectedCourseDetailsIndex = index
                    } label: {
                        VStack {
                            Size14RegularTextDarkestTitle(title: "Course: \(index)")
                            if index == selectedCourseIndex {
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
        .scrollTargetBehavior(.viewAligned)
        .scrollBounceBehavior(.basedOnSize)
        .scrollPosition(id: $selectedCourseIndex, anchor: .center)
        .animation(.smooth, value: selectedCourseIndex)
    }

    @ViewBuilder
    private func moduleListView(modules: [HModule]) -> some View {
        TabView(selection: $selectedCourseDetailsIndex) {
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
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onChange(of: selectedCourseDetailsIndex) {
            selectedCourseIndex = selectedCourseDetailsIndex
            print("🟪 ", selectedCourseDetailsIndex)
        }
        .animation(.smooth, value: selectedCourseDetailsIndex)
    }
}

// MARK: Extensions
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

extension View {
    func getSizeOfView(_ getSize: @escaping ((CGSize) -> Void)) -> some View {
        return self
            .background {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: SizePreferenceKey.self,
                        value: geometry.size
                    )
                    .onPreferenceChange(SizePreferenceKey.self) { value in
                        getSize(value)
                    }
                }
            }
    }
}
