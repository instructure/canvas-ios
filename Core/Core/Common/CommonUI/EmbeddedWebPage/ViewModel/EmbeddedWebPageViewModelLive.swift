//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Foundation
import WebKit

public class EmbeddedWebPageViewModelLive: EmbeddedWebPageViewModel {
    public enum EmbeddedWebPageType {
        case announcement(id: String)
        case discussion(id: String)

        public var assetID: String {
            switch self {
            case .announcement(let id): return id
            case .discussion(let id): return id
            }
        }
    }

    @Published public private(set) var subTitle: String?
    @Published public private(set) var contextColor: UIColor?

    public let navTitle: String
    public let url: URL

    /** The webview configuration to be used. In case of masquerading we can't use the default configuration because it will contain cookies with the original user's permissions. */
    public var webViewConfig: WKWebViewConfiguration {
        guard isMasqueradingUser else { return .defaultConfiguration }
        let result = WKWebViewConfiguration()
        result.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        return result
    }
    private let isMasqueradingUser: Bool

    private let context: Context
    private let env = AppEnvironment.shared
    private lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }
    private lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.update()
    }
    private lazy var group = env.subscribe(GetGroup(groupID: context.id)) { [weak self] in
        self?.update()
    }

    public init(
        context: Context,
        webPageType: EmbeddedWebPageType,
        environment: AppEnvironment = .shared
    ) {
        self.context = context
        self.isMasqueradingUser = environment.currentSession?.actAsUserID != nil

        var urlPathComponent: String
        switch webPageType {
        case .announcement(let id):
            // announcements/\(id) shows a navigation bar at the top
            // so we need to use discussion topics
            urlPathComponent = "discussion_topics/\(id)"
            navTitle = String(localized: "Announcement Details", bundle: .core)
        case .discussion(let id):
            urlPathComponent = "discussion_topics/\(id)"
            navTitle = String(localized: "Discussion Details", bundle: .core)
        }

        self.url = {
            guard var baseURL = AppEnvironment.shared.currentSession?.baseURL else {
                return URL(string: "/")! // should never happen
            }

            baseURL.appendPathComponent(context.pathComponent)
            baseURL.appendPathComponent(urlPathComponent)
            baseURL = baseURL.appendingQueryItems(
                URLQueryItem(name: "embed", value: "true"),
                URLQueryItem(name: "session_timezone", value: TimeZone.current.identifier),
                URLQueryItem(name: "session_locale", value: Locale.current.identifier.replacingOccurrences(of: "_", with: "-"))
            )

            return baseURL
        }()

        colors.refresh()

        if context.contextType == .course {
            course.refresh()
        } else {
            group.refresh()
        }
    }

    private func update() {
        guard
            let name = context.contextType == .course ? course.first?.name : group.first?.name,
            let color = context.contextType == .course ? course.first?.color : group.first?.color
        else {
            return
        }

        subTitle = name
        contextColor = color
    }
}
