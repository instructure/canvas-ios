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

    init(viewModel: ProgramsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        BaseHorizonScreen {
            InstUI.BaseScreen(
                state: viewModel.state,
                config: .init(refreshable: false)
            ) { proxy in
                VStack(alignment: .leading, spacing: 0) {
                    SectionTitleView(title: "your programs")
                    LargeTitleView(title: viewModel.title)
                        .padding(.bottom, 4)
                    BodyTextView(title: viewModel.institutionName)
                        .padding(.bottom, 4)
                    BodyTextView(title: viewModel.targetCompletion)
                        .padding(.bottom, 12)

                    Button {
                        print("change pacing tapped")
                    } label: {
                        Text("Change pacing")
                            .font(.regular16)
                            .padding(.horizontal, 8)
                            .frame(minHeight: 38)
                            .background(Color.backgroundLight)
                            .foregroundColor(Color.textDarkest)
                            .cornerRadius(3)
                    }
                    CertificateProgressBar(
                        maxWidth: proxy.size.width,
                        progress: viewModel.progress,
                        progressString: viewModel.progressString
                    )
                    whatsNextModuleView(proxy: proxy)
                    weeksView
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
            .background(Color.backgroundLightest)
        }
    }

    @ViewBuilder
    private func whatsNextModuleView(proxy: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitleView(title: "What's next")
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ProgramItemView(
                        screenWidth: proxy.size.width,
                        title: "Practice Quiz",
                        icon: Image(systemName: "doc"),
                        duration: "60 mins",
                        certificate: nil
                    )
                    ProgramItemView(
                        screenWidth: proxy.size.width,
                        title: "Video",
                        icon: Image(systemName: "doc"),
                        duration: "20 mins",
                        certificate: nil
                    )
                    ProgramItemView(
                        screenWidth: proxy.size.width,
                        title: "Video",
                        icon: Image(systemName: "doc"),
                        duration: "30 mins",
                        certificate: nil
                    )
                }
            }
        }
        .padding(.top, 16)
    }

    @State private var week1Expanded = false
    @State private var week2Expanded = false
    @State private var week3Expanded = false

    private var weeksView: some View {
        VStack(spacing: 0) {
            ExpandingWeekView(title: "week 1", items: [], isExpanded: $week1Expanded)
            ExpandingWeekView(title: "week 2", items: [], isExpanded: $week2Expanded)
            ExpandingWeekView(title: "week 3", items: [], isExpanded: $week3Expanded)
        }
    }
}

#Preview {
    ProgramsView(viewModel: .init())
}
