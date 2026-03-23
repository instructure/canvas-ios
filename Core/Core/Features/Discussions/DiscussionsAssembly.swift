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

import UIKit

public enum DiscussionsAssembly {
    public static let SourceViewKey = "SourceViewKey"

    public static func makeDiscussionDetailsViewController(
        context: Context,
        discussionId: String,
        isAnnouncement: Bool,
        url: URLComponents,
        environment: AppEnvironment
    ) -> UIViewController? {
        let isAppOffline = OfflineModeAssembly.make().isOfflineModeEnabled()

        // Mark announcement as read locally to allow Dashboard (or other screens) to update without API-refresh.
        // The actual mark-as-read request is sent by the Discussion Details webview.
        if isAnnouncement && !isAppOffline {
            DiscussionTopic.markAsRead(id: discussionId, database: environment.database)
        }

        if context.contextType == .course, !url.originIsModuleItemDetails {
            return ModuleItemSequenceViewController.create(
                env: environment,
                courseID: context.id,
                assetType: .discussion,
                assetID: discussionId,
                url: url
            )
        }

        if isAppOffline {
            return DiscussionDetailsViewController
                .create(
                    context: context,
                    topicID: discussionId,
                    env: environment
                )
        } else {
            let webPageModel = DiscussionDetailsWebViewModel(
                discussionId: discussionId,
                isAnnouncement: isAnnouncement
            )
            return makeEmbeddedWebPage(
                context: context,
                webPageModel: webPageModel,
                environment: environment
            )
        }
    }

    /// - parameters:
    ///   - routeUserInfo: If the discussion list is passed in this dictionary with the key `SourceViewKey`,
    ///    then the newly created discussion will be pushed after it has been created.
    public static func makeDiscussionCreateViewController(
        context: Context,
        isAnnouncement: Bool,
        routeUserInfo: [String: Any]? = [:],
        environment: AppEnvironment
    ) -> UIViewController {
        let newDiscussionPushSource = routeUserInfo?[SourceViewKey] as? UIViewController
        let webPageModel = DiscussionCreateWebViewModel(
            isAnnouncement: isAnnouncement,
            router: environment.router,
            newDiscussionPushSource: newDiscussionPushSource
        )
        return makeEmbeddedWebPage(
            context: context,
            webPageModel: webPageModel,
            environment: environment
        )
    }

    public static func makeDiscussionEditViewController(
        context: Context,
        topicID: String,
        isAnnouncement: Bool,
        environment: AppEnvironment
    ) -> UIViewController {
        let webPageModel = DiscussionEditWebViewModel(
            discussionId: topicID,
            isAnnouncement: isAnnouncement
        )
        return makeEmbeddedWebPage(
            context: context,
            webPageModel: webPageModel,
            environment: environment
        )
    }

    private static func makeEmbeddedWebPage(
        context: Context,
        webPageModel: EmbeddedWebPageViewModel,
        environment: AppEnvironment
    ) -> UIViewController {
        let viewModel = EmbeddedWebPageContainerViewModel(
            context: context,
            webPageModel: webPageModel,
            env: environment
        )
        return CoreHostingController(
            EmbeddedWebPageContainerScreen(
                viewModel: viewModel,
                isPullToRefreshEnabled: true
            ),
            env: environment
        )
    }
}
