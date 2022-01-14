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

    @Published public private(set) var topBarViewModel: TopBarViewModel?
    @Published public private(set) var courseTitle: String?
    @Published public private(set) var courseColor: UIColor?
    @Published public private(set) var currentPageURL: URL?
    @Published public private(set) var courseImageUrl: URL?
    public var reloadWebView: AnyPublisher<Void, Never> { reloadWebViewTrigger.eraseToAnyPublisher() }

    @Environment(\.appEnvironment) private var env
    private let context: Context
    private let reloadWebViewTrigger = PassthroughSubject<Void, Never>()
    private let selectedTabId: String?
    private lazy var tabs = env.subscribe(GetContextTabs(context: context)) { [weak self] in self?.tabsUpdated() }
    private lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in self?.courseUpdated() }
    private var moduleItemNotificationListener: NSObjectProtocol?
    private var subscriptions = Set<AnyCancellable>()

    /**
     - parameters:
        - selectedTabId: The identifier of the subject tab that should be selected when the page appears.
     */
    init(context: Context, selectedTabId: String? = nil) {
        self.context = context
        self.selectedTabId = selectedTabId
        reloadWebViewOnModuleItemProgressNotification()
        course.refresh()
        tabs.refresh()
    }

    private func reloadWebViewOnModuleItemProgressNotification() {
        moduleItemNotificationListener = NotificationCenter.default.addObserver(forName: .moduleItemRequirementCompleted, object: nil, queue: nil) { [weak self] _ in
            self?.reloadWebViewTrigger.send()
        }
    }

    private func tabsUpdated() {
        guard topBarViewModel == nil, !tabs.isEmpty else { return }
        var tabItems: [TopBarItemViewModel] = []
        tabs.filter({ $0.type == .internal && !($0.hidden ?? false)}).forEach { tab in
            tabItems.append(TopBarItemViewModel(tab: tab, iconImage: tabIconImage(for: tab.id)))
        }
        if !tabs.filter({$0.id.contains("context_external_tool_") && !($0.hidden ?? false) }).isEmpty {
            let resurceTabItem = TopBarItemViewModel(icon: .k5resources, label: Text("Resources", bundle: .core))
            resurceTabItem.id = "resources"
            tabItems.append(resurceTabItem)
        }
        topBarViewModel = TopBarViewModel(items: tabItems)
        topBarViewModel!.selectedItemIndexPublisher
            .sink { [weak self] _ in self?.tabChanged() }
            .store(in: &subscriptions)

        if let selectedTabId = selectedTabId, let selectedTabIndex = tabItems.firstIndex(where: { $0.id == selectedTabId }) {
            topBarViewModel?.selectedItemIndex = selectedTabIndex
        }
    }

    private var masqueradedSessionRequest: APITask?

    private func tabChanged() {
        guard let topBarViewModel = topBarViewModel else { return }
        let url = pageUrl(for: topBarViewModel.selectedItemId)

        if env.currentSession?.actAsUserID != nil, let url = url {
            startMasqueradedSession(for: url)
        } else {
            currentPageURL = url
        }
    }

    private func startMasqueradedSession(for url: URL) {
        masqueradedSessionRequest?.cancel()
        masqueradedSessionRequest = env.api.makeRequest(GetWebSessionRequest(to: url)) { [weak self] response, _, _ in
            performUIUpdate {
                self?.currentPageURL = response?.session_url ?? url
                self?.masqueradedSessionRequest = nil
            }
        }
    }

    private func courseUpdated() {
        guard let course = course.first else { return }
        courseTitle = course.name
        courseColor = course.color
        courseImageUrl = course.imageDownloadURL
    }

    private func pageUrl(for itemId: String?) -> URL? {
        let path = context.pathComponent
        var urlComposition = URLComponents(string: env.api.baseURL.absoluteString + "/\(path)")
        urlComposition?.queryItems = [URLQueryItem(name: "embed", value: "true")]
        urlComposition?.fragment = itemId
        return urlComposition?.url
    }
}

extension K5SubjectViewModel {

    func tabIconImage(for tabId: String) -> Image? {
        switch tabId {
        case "home": return .k5homeroom
        case "schedule": return .k5schedule
        case "modules": return .moduleLine
        case "grades": return .k5grades
        default: return nil
        }
    }
}
