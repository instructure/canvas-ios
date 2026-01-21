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
import HorizonUI

struct LearnView: View {
    @State private var isShowTabs: Bool = true
    @State private var selectedTabIndex: Int? = 0

    private let listCourseView: LearnCourseListView
    private let listProgramView: LearnProgramListView

    init() {
        self.listCourseView = LearnCourseListAssembly.makeView()
        self.listProgramView = LearnProgramListAssembly.makeView()
    }

    var body: some View {
        VStack(spacing: 0) {
            tabDetailsView()
                .onPreferenceChange(HeaderVisibilityKey.self) { isShow in
                    isShowTabs = isShow
                }
        }
        .safeAreaInset(edge: .top, spacing: .zero) {
            if isShowTabs { tabsView }
        }
        .toolbar(.hidden)
        .animation(.linear, value: isShowTabs)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.huiColors.surface.pagePrimary)
        .dismissKeyboardOnTap()
    }

    private func tabDetailsView() -> some View {
        TabView(selection: $selectedTabIndex) {
            ForEach(Array(LearnTabs.allCases.enumerated()), id: \.offset) { index, tab in
                Group {
                    switch tab {
                    case .courses: listCourseView
                    case .programs: listProgramView
                    case .learningLibrary: Text("learningLibrary")
                    }
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    private var tabsView: some View {
        HorizonUI.Tabs(
            tabs: LearnTabs.allCases.map(\.localizedString),
            selectTabIndex: Binding(
                get: { selectedTabIndex },
                set: { selectedTabIndex = $0 ?? 0 }
            )
        )
        .padding(.top, .huiSpaces.space8)
        .padding(.bottom, .huiSpaces.space24)
        .background(Color.huiColors.surface.pagePrimary)
    }
}

#Preview {
    LearnView()
}
