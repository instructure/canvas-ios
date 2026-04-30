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

import Core
import SwiftUI

struct NGCourseDetailsView: View {
    @ObservedObject var viewModel: CourseDetailsViewModel
    @State private var selectedTab: Tab = .home
    @State private var screenConfig: BaseScreenConfig = .init(backgroundColor: .backgroundLight)

    private var screenState: ScreenState {
        switch viewModel.state {
        case .loading: return .loading
        case .empty: return .empty
        case .data: return .data
        }
    }

    var body: some View {
        BaseScreen(
            state: screenState,
            config: screenConfig,
            refreshAction: { completion in
                Task {
                    await viewModel.refresh()
                    completion()
                }
            }
        ) { _ in
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(viewModel.courseColor))
                        .frame(width: 48, height: 84)
                    Text(viewModel.courseName)
                        .font(.semibold16)
                        .foregroundColor(.textDarkest)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Picker("", selection: $selectedTab) {
                    ForEach(Tab.allCases) { tab in
                        Text(tab.label).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.top, 8)
                .padding(.bottom, 16)

                Text(selectedTab.label)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .navigationTitle(viewModel.navigationBarTitle)
        .onAppear {
            viewModel.viewDidAppear()
        }
    }
}

private extension NGCourseDetailsView {
    enum Tab: Int, CaseIterable, Identifiable {
        case home, modules, myWork, more

        var id: Int { rawValue }

        var label: String {
            switch self {
            case .home: return String(localized: "Home", bundle: .nextgen)
            case .modules: return String(localized: "Modules", bundle: .nextgen)
            case .myWork: return String(localized: "My work", bundle: .nextgen)
            case .more: return String(localized: "More", bundle: .nextgen)
            }
        }
    }
}
