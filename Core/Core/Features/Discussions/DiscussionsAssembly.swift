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

public enum DiscussionsAssembly {
    public static let SourceViewKey = "SourceViewKey"

    /// - parameters:
    ///   - routeUserInfo: If the discussion list is passed in this dictionary with the key `SourceViewKey`,
    ///    then the newly created discussion will be pushed after it has been created.
    public static func makeDiscussionCreateViewController(
        context: Context,
        isAnnouncement: Bool,
        routeUserInfo: [String: Any]? = [:]
    ) -> UIViewController {
        let newDiscussionPushSource = routeUserInfo?[SourceViewKey] as? UIViewController
        let webPageModel = DiscussionCreateWebViewModel(
            isAnnouncement: isAnnouncement,
            newDiscussionPushSource: newDiscussionPushSource
        )
        return makeEmbeddedWebPage(
            context: context,
            webPageModel: webPageModel
        )
    }

    public static func makeDiscussionEditViewController(
        context: Context,
        topicID: String,
        isAnnouncement: Bool
    ) -> UIViewController {
        let webPageModel = DiscussionEditWebViewModel(
            discussionId: topicID,
            isAnnouncement: isAnnouncement
        )
        return makeEmbeddedWebPage(
            context: context,
            webPageModel: webPageModel
        )
    }

    private static func makeEmbeddedWebPage(
        context: Context,
        webPageModel: EmbeddedWebPageViewModel
    ) -> UIViewController {
        let viewModel = EmbeddedWebPageContainerViewModel(
            context: context,
            webPageModel: webPageModel
        )
        return CoreHostingController(
            EmbeddedWebPageContainerScreen(
                viewModel: viewModel,
                isPullToRefreshEnabled: true
            )
        )
    }
}
