//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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
import SwiftUI

public class K5SubjectViewModel: ObservableObject {

    @Environment(\.appEnvironment) private var env

    @Published var topBarViewModel: TopBarViewModel?
    @Published var subjectTitle: String?
    @Published var subjectColor: UIColor?
    @Published var currentPageURL: URL?

    private let context: Context

    private lazy var tabs = env.subscribe(GetContextTabs(context: context)) { [weak self] in
        self?.tabsUpdated()
    }

    private lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.courseUpdated()
    }

    private var topBarChangeListener: AnyCancellable?

    private func tabsUpdated() {
        guard topBarViewModel == nil, !tabs.isEmpty else { return }
        var tabItems: [TopBarItemViewModel] = []
        tabs.filter({ $0.type == .internal && !($0.hidden ?? false)}).forEach { tab in
            tabItems.append(TopBarItemViewModel(tab: tab))
        }
        if !tabs.filter({$0.id.contains("context_external_tool_") && !($0.hidden ?? false) }).isEmpty {
            let resurceTabItem = TopBarItemViewModel(icon: .k5resources, label: Text("Resources", bundle: .core))
            resurceTabItem.id = "resources"
            tabItems.append(resurceTabItem)
        }
        topBarViewModel = TopBarViewModel(items: tabItems)
        // Propagate changes of the underlying view model to this observable class because there's no native support for nested ObservableObjects
        topBarChangeListener = topBarViewModel?.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    private func courseUpdated() {
        subjectTitle = course.first?.name
        subjectColor = course.first?.color
    }

    func pageUrl(with itemId: String?) -> URL? {
        let path = context.pathComponent
        var urlComposition = URLComponents(string: env.api.baseURL.absoluteString + "/\(path)")
        urlComposition?.queryItems = [URLQueryItem(name: "embed", value: "true")]
        urlComposition?.fragment = itemId
        return urlComposition?.url
    }

    init(context: Context) {
        self.context = context
        course.refresh()
        tabs.refresh()
    }
}
