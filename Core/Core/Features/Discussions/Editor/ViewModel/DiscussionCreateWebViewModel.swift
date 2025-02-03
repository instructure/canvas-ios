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

import WebKit

public struct DiscussionCreateWebViewModel: EmbeddedWebPageViewModel {
    public let urlPathComponent: String = "/discussion_topics/new"
    public let navigationBarTitle: String
    public let queryItems: [URLQueryItem]

    private let router: Router
    private let newDiscussionPushSource: UIViewController?

    /// - parameters:
    ///   - newDiscussionPushSource: If this variable is present then after creating a discussion,
    ///   the newly created discussion will be pushed using this view controller.
    ///   If this variable is nil then only the create modal will be dismissed.
    public init(
        isAnnouncement: Bool,
        router: Router = AppEnvironment.shared.router,
        newDiscussionPushSource: UIViewController?
    ) {
        navigationBarTitle = isAnnouncement ? String(localized: "New Announcement", bundle: .core)
                                            : String(localized: "New Discussion", bundle: .core)
        queryItems = isAnnouncement ? [URLQueryItem(name: "is_announcement", value: "true")]
                                    : []
        self.router = router
        self.newDiscussionPushSource = newDiscussionPushSource
    }

    public func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {
        guard let discussionTopicId = webView.url?.discussionTopicId else {
            return
        }

        // At this point we are pretty sure that we are navigating to the new discussion

        guard let discussionUrl = webView.url else {
            return
        }

        fetchNewDiscussion(
            discussionUrl: discussionUrl,
            topicId: discussionTopicId
        )
        dismissCreateScreenAndShowNewDiscussion(
            discussionUrl: discussionUrl,
            webView: webView
        )
    }

    /// Saves the new discussion so it will appear in the discussion list.
    private func fetchNewDiscussion(
        discussionUrl: URL,
        topicId: String
    ) {
        guard let context = Context(url: discussionUrl) else {
            return
        }
        let useCase = GetDiscussionTopic(context: context, topicID: topicId)
        useCase.fetch()
    }

    private func dismissCreateScreenAndShowNewDiscussion(
        discussionUrl: URL,
        webView: WKWebView
    ) {
        guard let webViewController = webView.viewController else {
            return
        }

        router.dismiss(webViewController) { [router, newDiscussionPushSource] in
            if let newDiscussionPushSource {
                router.route(to: discussionUrl, from: newDiscussionPushSource, options: .detail)
            }
        }
    }
}

private extension URL {

    var discussionTopicId: String? {
        guard
            pathComponents.count > 2,
            pathComponents[pathComponents.count - 2] == "discussion_topics",
            let topicIdString = pathComponents.last,
            topicIdString.isNotEmpty,
            topicIdString.containsOnlyNumbers
        else {
            return nil
        }

        return topicIdString
    }
}
