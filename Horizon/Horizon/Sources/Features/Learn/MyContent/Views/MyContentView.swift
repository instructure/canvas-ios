//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Combine
import HorizonUI
import SwiftUI

struct MyContentView: View {
    @State private var isShowTabs: Bool = true
    @State private var selectedTab: Tabs = .inProgress
    private let inProgressView: LearnItemView
    private let completedView: LearnItemView
    private let savedView: LearningLibraryBookmarksView

    init() {
        inProgressView = LearnItemAssembly.makeView()
        completedView =  LearnItemAssembly.makeView(status: [.completed])
        savedView = LearningLibraryBookmarkAssembly.makeView()
    }
    var body: some View {
        VStack {
            if isShowTabs {
                tabsView
            }

            contentView
                .animation(.easeInOut, value: selectedTab)
                .onPreferenceChange(HeaderVisibilityKey.self) { isShow in
                    isShowTabs = isShow
                }
            Spacer()
        }
        .animation(.easeInOut, value: selectedTab)
    }

    private var tabsView: some View {
        HStack(spacing: .huiSpaces.space8) {
            ForEach(Tabs.allCases, id: \.self) { tab in
                FilterButton(title: tab.name, isSelected: selectedTab == tab) {
                    selectedTab = tab
                }
                .fixedSize(horizontal: true, vertical: false)
            }
            Spacer()
        }
        .padding(.horizontal, .huiSpaces.space24)
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedTab {
        case .inProgress:
            inProgressView
        case .saved:
            savedView
        case .completed:
            completedView
        }
    }
}

extension MyContentView {
    enum Tabs: CaseIterable {
        case inProgress
        case saved
        case completed

        var name: String {
            switch self {
            case .inProgress: String(localized: "In Progress")
            case .saved: String(localized: "Saved")
            case .completed: String(localized: "Completed")
            }
        }
    }
}

#Preview {
    MyContentView()
}
