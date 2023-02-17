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
import WebKit

public class K5SubjectViewModel: ObservableObject {

    @Published public private(set) var topBarViewModel: TopBarViewModel?
    @Published public private(set) var courseTitle: String?
    @Published public private(set) var courseColor: UIColor?
    @Published public private(set) var currentPageURL: URL?
    @Published public private(set) var courseBannerImageUrl: URL?
    @Published public private(set) var courseImageUrl: URL?
    public var courseID: String {
        course.first?.id ?? ""
    }
    public private(set) lazy var reloadWebView: AnyPublisher<Void, Never> = makeWebViewReloadTrigger()

    /** The webview configuration to be used. In case of masquerading we can't use the default configuration because it will contain cookies with the original user's permissions. */
    public var config: WKWebViewConfiguration { masqueradedSession.config }

    private let env = AppEnvironment.shared
    private let context: Context
    private let selectedTabId: String?
    private lazy var tabs = env.subscribe(GetContextTabs(context: context)) { [weak self] in self?.tabsUpdated() }
    private lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in self?.courseUpdated() }
    private var subscriptions = Set<AnyCancellable>()
    private lazy var masqueradedSession: K5SubjectViewMasqueradedSession = {
        let session = K5SubjectViewMasqueradedSession(env: env)
        session.sessionURL
            .sink { [weak self] in self?.currentPageURL = $0 }
            .store(in: &subscriptions)
        return session
    }()

    /**
     - parameters:
        - selectedTabId: The identifier of the subject tab that should be selected when the page appears.
     */
    init(context: Context, selectedTabId: String? = nil) {
        self.context = context
        self.selectedTabId = selectedTabId
        course.refresh()
        tabs.refresh()
    }

    private func tabsUpdated() {
        guard topBarViewModel == nil, !tabs.isEmpty else { return }
        var tabItems: [TopBarItemViewModel] = []
        tabs.filter({ $0.type == .internal && !($0.hidden ?? false)}).forEach { tab in
            tabItems.append(TopBarItemViewModel(tab: tab, iconImage: tabIconImage(for: tab.id)))
        }
        if !tabs.filter({$0.id.contains("context_external_tool_") && !($0.hidden ?? false) }).isEmpty {
            let resurceTabItem = TopBarItemViewModel(id: "resources", icon: .k5resources, label: Text("Resources", bundle: .core))
            tabItems.append(resurceTabItem)
        }
        topBarViewModel = TopBarViewModel(items: tabItems)
        topBarViewModel!.selectedItemIndexPublisher
            .sink { [weak self] _ in self?.tabChanged() }
            .store(in: &subscriptions)

        if let selectedTabId = selectedTabId, let selectedTabIndex = tabItems.firstIndex(where: { $0.id == selectedTabId }) {
            topBarViewModel?.selectedItemIndex = selectedTabIndex
        }

        // After setting up the default tab so we won't report home view all the time
        setupScreenViewLogging()
    }

    private func tabChanged() {
        guard let topBarViewModel = topBarViewModel else { return }
        let url = pageUrl(for: topBarViewModel.selectedItemId)

        if masqueradedSession.handlesTabChangeEvents, let url = url {
            masqueradedSession.tabChanged(toIndex: topBarViewModel.selectedItemIndex, toURL: url)
        } else {
            currentPageURL = url
        }
    }

    private func courseUpdated() {
        guard let course = course.first else { return }
        courseTitle = course.name
        courseColor = course.color
        courseBannerImageUrl = course.bannerImageDownloadURL
        courseImageUrl = course.imageDownloadURL
    }

    private func pageUrl(for itemId: String?) -> URL? {
        let path = context.pathComponent
        var urlComposition = URLComponents(string: env.api.baseURL.absoluteString + "/\(path)")
        urlComposition?.queryItems = [URLQueryItem(name: "embed", value: "true")]
        urlComposition?.fragment = itemId
        return urlComposition?.url
    }

    private func setupScreenViewLogging() {
        guard let topBarViewModel = topBarViewModel else { return }
        topBarViewModel.selectedItemIndexPublisher
            .removeDuplicates()
            .compactMap { topBarViewModel.items[$0].id }
            .sink { Analytics.shared.logScreenView(route: "/homeroom/subject/\($0)") }
            .store(in: &subscriptions)
    }

    private func makeWebViewReloadTrigger() -> AnyPublisher<Void, Never> {
        let moduleRequirementCompletedPublisher =
            NotificationCenter.default
                .publisher(for: .moduleItemRequirementCompleted)
                .map { _ in () } // map received notification to Void
        let appWillEnterForegroundWhileModulesSelectedPublisher =
            NotificationCenter.default
                .publisher(for: UIApplication.willEnterForegroundNotification)
                .compactMap { [weak self] _ -> Void? in
                    guard let topBarViewModel = self?.topBarViewModel,
                          topBarViewModel.selectedItemId == "modules"
                    else {
                        return nil
                    }

                    return ()
                }

        return Publishers.Merge(moduleRequirementCompletedPublisher, appWillEnterForegroundWhileModulesSelectedPublisher)
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
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
