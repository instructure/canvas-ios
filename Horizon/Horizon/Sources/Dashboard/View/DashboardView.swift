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

struct DashboardView: View {
    @ObservedObject private var viewModel: DashboardViewModel

    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        InstUI.BaseScreen(
            state: viewModel.state,
            config: .init(refreshable: false)
        ) { proxy in
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.title)
                    .font(.bold28)
                    .foregroundColor(.textDarkest)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                Text("BIOLOGY CERTIFICATE #17491")
                    .font(.regular12)
                    .foregroundColor(.textDark)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 24)
                CertificateProgressBar(
                    maxWidth: proxy.size.width,
                    progress: viewModel.progress,
                    progressString: viewModel.progressString
                )
                currentModuleView
                whatsNextModuleView(proxy: proxy)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .background(Color.backgroundLightest)
    }

    private var currentModuleView: some View {
        ZStack {
            VStack {
                Rectangle()
                    .fill(Color.backgroundLightest)
                    .frame(height: 200)
                    .padding(16)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Short form text")
                            .font(.bold16)
                            .foregroundStyle(Color.textDarkest)
                        Text("20 MINS")
                            .font(.regular12)
                            .foregroundStyle(Color.textDark)
                    }
                    Spacer()
                    Button {
                        print("tapped")
                    } label: {
                        Text("Start")
                            .font(.regular16)
                            .padding(.all, 8)
                            .background(Color.backgroundDarkest)
                            .foregroundColor(Color.textLightest)
                            .cornerRadius(3)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(Color.backgroundLight)
        .padding(.top, 16)
    }

    @ViewBuilder
    private func whatsNextModuleView(proxy: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("WHAT'S NEXT")
                .font(.regular12)
                .foregroundColor(.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ProgramItemView(
                        screenWidth: proxy.size.width,
                        title: "Practice Quiz",
                        icon: Image(systemName: "doc"),
                        duration: "60 mins",
                        certificate: "Biology certificate"
                    )
                    ProgramItemView(
                        screenWidth: proxy.size.width,
                        title: "Video",
                        icon: Image(systemName: "doc"),
                        duration: "20 mins",
                        certificate: "Biology certificate"
                    )
                    ProgramItemView(
                        screenWidth: proxy.size.width,
                        title: "Video",
                        icon: Image(systemName: "doc"),
                        duration: "30 mins",
                        certificate: "Biology certificate"
                    )
                }
            }
        }
        .padding(.top, 16)
    }
}

#Preview {
    DashboardView(viewModel: .init())
}
